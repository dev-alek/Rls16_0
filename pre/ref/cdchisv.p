block-level on error undo, throw.
define input parameter p-d-card  like ub.c-dc-hist.d-card no-undo .
define input parameter p-chip-num like ub.c-dc-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-dc-hist.corr-user-db-num no-undo .
define input parameter p-obj-type like ub.c-dc-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-dc-hist.obj-code no-undo .
define input parameter p-host-code like ub.c-dc-hist.host-code no-undo .
define input parameter p-subject like ub.c-dc-hist.subject no-undo .
define input parameter p-action   like ub.c-dc-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdchisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cdchisv.p $":U .
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
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info2 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info2, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info2 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info2, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info2, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info2, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info2, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info2, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info2, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info2 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info2, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info2 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure disproph_write-dis-card-property-proc  :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-d-card      like ub.dis-card-property.d-card no-undo .
define input parameter p-dt-code      like ub.dis-card-property.dt-code no-undo .
define input parameter p-host-code   like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type    like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code    like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code    like ub.dis-card-property.dtm-code no-undo .
define input parameter p-card-num    like ub.dis-card-property.card-num  no-undo .
define input parameter p-main-card   like ub.dis-card-property.main-card  no-undo .
define input parameter p-first-card  like ub.dis-card-property.first-card  no-undo .
define input parameter p-first-main-card  like ub.dis-card-property.first-main-card  no-undo .
define input parameter p-node-code   like ub.dis-card-property.node-code no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define variable v-send as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not available buf_dis-card-property and not p-action = integer('1':U) then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена запись СВОЙСТВА ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
  v-send = integer('0':U).
  if not p-action = integer('1':U) then do:
    if available buf_dis-card then do:
      if g#news then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      end.
      else do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-from-prim'
  ,output v-send
  ) no-error .
      end.
    end.
  end.
  if v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    if p-action = integer('1':U) then do:
      create buf_c-dis-card-property.
      assign
      buf_c-dis-card-property.d-card            = p-d-card
      buf_c-dis-card-property.card-num          = p-card-num
      buf_c-dis-card-property.host-code         = p-host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.dt-code           = p-dt-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.main-card         = p-main-card
      buf_c-dis-card-property.first-main-card   = p-first-main-card
      buf_c-dis-card-property.first-card        = p-first-card
      buf_c-dis-card-property.chip-num          = (if p-chip-num = 0
                                                   then next-value (s-dc-chip, ub)
                                                   else p-chip-num)
      buf_c-dis-card-property.corr-time         = (if p-corr-time = ?
                                                   then v-time
                                                   else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num  = g#db-num
      buf_c-dis-card-property.corr-user-name    = if g#news then (chr(4) +  'СПН':U) else g#userid
      buf_c-dis-card-property.corr-date         = (if p-corr-date = ?
                                                   then v-date
                                                   else p-corr-date)
      .
    end.
    else do:
      create buf_c-dis-card-property.
      buffer-copy buf_dis-card-property to buf_c-dis-card-property
      assign
      buf_c-dis-card-property.d-card             = buf_dis-card-property.d-card
      buf_c-dis-card-property.card-num           = buf_dis-card-property.card-num
      buf_c-dis-card-property.dt-code             = buf_dis-card-property.dt-code
      buf_c-dis-card-property.main-card          = buf_dis-card-property.main-card
      buf_c-dis-card-property.first-main-card    = buf_dis-card-property.first-main-card
      buf_c-dis-card-property.first-card         = buf_dis-card-property.first-card
      buf_c-dis-card-property.host-code          = buf_dis-card-property.host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.chip-num           = (if p-chip-num = 0
                                                    then next-value (s-dc-chip, ub)
                                                    else p-chip-num)
      buf_c-dis-card-property.corr-time          = (if p-corr-time = ?
                                                    then v-time
                                                    else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num   = g#db-num
            buf_c-dis-card-property.corr-user-name    = (if g#news
                                                   then (chr(4) +  'СПН':U)
                                                   else (if g#esys
                                                         then (chr(4) +  'ВС':U)
                                                         else g#userid
                                                         )
                                                   )
      buf_c-dis-card-property.corr-date          = (if p-corr-date = ?
                                                    then v-date
                                                    else p-corr-date)
      .
      run gen-key-rec in this-procedure (
                                          input 'dis-card-property':U
                                        ,input buffer buf_dis-card-property:handle
                                        ,output v-uniq-key-rec).
    end.
    if p-chip-num = 0   then do:
      create buf_c-dc-hist.
      buffer-copy buf_c-dis-card-property to buf_c-dc-hist
      assign
      buf_c-dc-hist.action =  p-action
      buf_c-dc-hist.subject = 'dis-card-property':U
      buf_c-dc-hist.is-news = g#news
      buf_c-dc-hist.source-type = p-source-type
      buf_c-dc-hist.source-ref = p-source-ref
      buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
      .
    end.
    assign
    p-chip-num = buf_c-dis-card-property.chip-num
    p-corr-date = buf_c-dis-card-property.corr-date
    p-corr-time = buf_c-dis-card-property.corr-time
    .
    run disproph_send-nws in this-procedure (
                                              buffer buf_c-dis-card-property
                                             ,buffer buf_c-dc-hist
                                             ,buffer buf_dis-card
                                              ).
    end.
  end.
end procedure.
procedure disproph_send-nws :
define parameter buffer buf_c-dis-card-property for ub.c-dis-card-property.
define parameter buffer buf_c-dc-hist for ub.c-dc-hist.
define parameter buffer buf_Dis-card for ub.dis-card.
define variable v-dh-hn as integer no-undo .
main-block:
do
on error undo, return error return-value
:
  if g#news
  and g#db-num > 0
  and buf_c-dis-card-property.corr-user-db-num <> g#db-num
  then return.
  if g#db-num = 0
  or (g#news
      and g#db-num > 0
      and buf_c-dis-card-property.corr-user-name = (chr(4) +  'СПН':U)
      )
  then do:
    if not available buf_dis-card then do:
      find first buf_dis-card no-lock where
                buf_Dis-card.d-card = buf_c-dis-card-property.d-card no-error.
    end.
    if not available buf_dis-card then do:
      assign
      v-dh-hn = integer('0':U).
    end.
    else do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_c-dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-to-nws'
  ,output v-dh-hn
  ) no-error .
    end.
    if v-dh-hn >= 0 then do:
      run str/callnews.p (
        input 'c-dis-card-property':U
        ,input (buffer buf_c-dis-card-property:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
      end.
      if available buf_c-dc-hist then do:
        run str/callnews.p (
          input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
        end.
      end.
    end.
  end.
end.
end procedure.
procedure discprop-node-code :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-format as character no-undo .
define output parameter p-label as character no-undo .
define output parameter p-range as integer no-undo .
define output parameter p-rw-option as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code no-error .
if available buf_prop-head then do:
  if p-node-code > 0 then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = p-dtm-code
          and buf_prop-map.node-code = p-node-code no-error .
    if available buf_prop-map then do:
      assign
      p-data-type = buf_prop-map.node-value-type
      p-format = buf_prop-map.node-format
      p-label = buf_prop-map.node-label
      p-rw-option = buf_prop-map.rw-option
      .
    end.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  12.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  3.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  2.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  1.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  = "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  0.
  end.
end.
end.
end procedure.
procedure discprop-initial:
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-init-value-character as character no-undo .
define output parameter p-init-value-date as date no-undo .
define output parameter p-init-value-decimal as decimal no-undo .
define output parameter p-init-value-integer as integer no-undo .
define output parameter p-init-value-logical as logical no-undo .
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-map no-lock where
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code = p-node-code no-error.
if not available buf_prop-map then return error substitute("Не найдено свойство &1 для объекта &2"
                                                            , p-node-code
                                                            , p-dtm-code).
assign
p-init-value-character = buf_prop-map.init-value-character
p-init-value-date = buf_prop-map.init-value-date
p-init-value-decimal = buf_prop-map.init-value-decimal
p-init-value-integer = buf_prop-map.init-value-integer
p-init-value-logical = buf_prop-map.init-value-logical
.
end procedure.
Function discprop-usercanedit returns logical (  input p-dtm-code as integer, input p-db-num as integer):
define buffer buf_attr-prop for ub.attr-prop.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
      and buf_attr-prop.templ-rl-root = p-dtm-code
      and buf_attr-prop.upper-prop-code = "UserCanEdit"
      and buf_attr-prop.prop-code = (if p-db-num = 0 then 'DB0' else 'DBR':U) no-error.
if not available buf_attr-prop
or logical(buf_attr-prop.property-value) = no then do:
  return no.
end.
return yes.
end function.
procedure discprop-edit :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-edit-menu-section-num as integer no-undo .
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
     and  buf_attr-prop.templ-rl-root = integer(entry(1, p-dtm-code-node-name, chr(4)))
     and  buf_attr-prop.upper-prop-code = "ManualEdit":U
     and  buf_attr-prop.prop-code = "SectionNum":U no-error .
  if available buf_attr-prop then do:
    assign
    p-edit-menu-section-num = integer(buf_attr-prop.property-value).
  end.
end.
end procedure.
procedure discprop-node-name :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-tool-tip as character no-undo .
define output parameter p-node-label as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) )) no-error .
  assign
  p-tool-tip   = if available buf_prop-head
                 then buf_prop-head.prop-des
                 else entry(1, p-dtm-code-node-name, chr(4) )
  p-node-label = (if available buf_prop-head
                  then buf_prop-head.prop-label
                  else '':U)
  .
  if entry(2, p-dtm-code-node-name, chr(4) ) <> "" then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) ))
        and  buf_prop-map.node-code = integer(entry(2, p-dtm-code-node-name, chr(4) )) no-error.
    if available buf_prop-map then do:
      assign
      p-tool-tip   = buf_prop-map.node-description
      p-node-label = (if available buf_prop-head
                      then buf_prop-head.prop-label
                      else '':U) + ":" + buf_prop-map.node-label
      .
    end.
  end.
end.
end procedure.
procedure discprop-write :
define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code        like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code         like ub.dis-card-property.dt-code    no-undo .
define input parameter p-sum-id          like ub.dis-card-property.sum-id     no-undo .
define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
define input parameter p-source-type     as character no-undo .
define input parameter p-source-ref      as character no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  define buffer buf_dis-card-property for ub.dis-card-property .
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_prop-ref for ub.prop-ref.
  define variable v-data-type      as character no-undo .
  define variable v-data-type-1    as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-rw-option      as character no-undo .
  run discprop-node-code in this-procedure
    (
     input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  v-data-type-1 = entry(1, v-data-type).
  if p-dt-code = ? then do:
    find buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = p-dtm-code
    and buf_prop-ref.sum-id = p-sum-id no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Неопределен или неоднозначен ИТОГ/СРЕЗ для объекта-операнда &1 &2"
                                    ,p-dtm-code
                                    ,p-sum-id).
    end.
    assign
    p-dt-code = buf_prop-ref.dt-code.
  end.
  if discprop-usercanedit ( input p-dtm-code, input g#db-num)  = no then do:
    undo, return error "Нельзя редактировать свойство в данной БД".
  end.
  run discprop-check in this-procedure (
                                          input v-range
                                        ,input p-d-card
                                        ,input p-host-code
                                        ,input p-obj-type
                                        ,input p-obj-code
                                        ,input p-dtm-code
                                        ,input p-node-code
                                        ,input p-dt-code
                                      ) no-error .
  if error-status:error then undo,  return error return-value .
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error .
    find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card.
  if not available buf_dis-card-property then do:
    create buf_dis-card-property .
    assign
      buf_dis-card-property.d-card    = p-d-card
      buf_dis-card-property.host-code = p-host-code
      buf_dis-card-property.obj-type  = p-obj-type
      buf_dis-card-property.obj-code  = p-obj-code
      buf_dis-card-property.dt-code = p-dt-code
      buf_dis-card-property.node-code = p-node-code
      buf_dis-card-property.dtm-code = p-dtm-code
      buf_dis-card-property.sum-id   = p-sum-id
      buf_dis-card-property.card-num  = buf_dis-card.card-num
      buf_dis-card-property.main-card  = buf_dis-card.main-card
      buf_dis-card-property.first-card  = buf_dis-card.first-card
      buf_dis-card-property.first-main-card  = buf_dis-card.first-main-card
    .
  end.
  else do:
    if (v-data-type-1 = 'character':U
    and buf_dis-card-property.property-value-character = p-value-character)
    or  (v-data-type-1 = 'date':U
        and buf_dis-card-property.property-value-date = p-value-date)
    or  (v-data-type-1 = 'decimal':U
        and buf_dis-card-property.property-value-decimal = p-value-decimal)
    or  (v-data-type-1 = 'integer':U
        and buf_dis-card-property.property-value-integer = p-value-integer)
    or  (v-data-type-1 = 'logical':U
        and buf_dis-card-property.property-value-logical = p-value-logical)
    then return.
  end.
  run disproph_write-dis-card-property-proc  in this-procedure (
          buffer buf_dis-card-property
          ,buffer Buf_dis-card
          ,input p-d-card
          ,input p-dt-code
          ,input p-host-code
          ,input p-obj-type
          ,input p-obj-code
          ,input p-dtm-code
          ,input buf_dis-card.card-num
          ,input buf_dis-card.main-card
          ,input buf_dis-card.first-card
          ,input buf_dis-card.first-main-card
          ,input p-node-code
          ,input (if new(buf_dis-card-property) then integer('1':U) else integer('2':U))
          ,input p-source-type
          ,input p-source-ref
          ,input-output p-chip-num
          ,input-output p-corr-date
          ,input-output p-corr-time
          ).
  assign
  buf_dis-card-property.property-value-character = (if v-data-type-1 = 'character':U
                                                    then p-value-character
                                                    else buf_dis-card-property.property-value-character)
  buf_dis-card-property.property-value-date      = (if v-data-type-1 = 'date':U
                                                    then p-value-date
                                                    else buf_dis-card-property.property-value-date)
  buf_dis-card-property.property-value-decimal   = (if v-data-type-1 = 'decimal':U
                                                    then p-value-decimal
                                                    else buf_dis-card-property.property-value-decimal)
  buf_dis-card-property.property-value-integer   = (if v-data-type-1 = 'integer':U
                                                    then p-value-integer
                                                    else buf_dis-card-property.property-value-integer)
  buf_dis-card-property.property-value-logical   = (if v-data-type-1 = 'logical':U
                                                    then p-value-logical
                                                    else buf_dis-card-property.property-value-logical)
  buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U)
  .
  release buf_dis-card-property no-error .
  if error-status:error then do:
    return error return-value .
  end.
end.
end procedure.
procedure discprop-delete :
define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define output parameter p-deleted  as logical no-undo.
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define buffer buf_dis-card-property for ub.dis-card-property .
define buffer buf_dis-card for ub.dis-card.
define variable v-data-type      as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-range          as integer   no-undo .
define variable v-rw-option      as character   no-undo .
  run discprop-node-code in this-procedure
    (input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error NO-WAIT.
  if not available buf_dis-card-property then do:
    p-deleted = no.
  end.
  else do:
    run disproph_write-dis-card-property-proc  in this-procedure (
         buffer buf_dis-card-property
        ,buffer buf_dis-card
        ,input buf_dis-card-property.d-card
        ,input buf_dis-card-property.dt-code
        ,input buf_dis-card-property.host-code
        ,input buf_dis-card-property.obj-type
        ,input buf_dis-card-property.obj-code
        ,input buf_dis-card-property.dtm-code
        ,input buf_dis-card-property.card-num
        ,input buf_dis-card-property.main-card
        ,input buf_dis-card-property.first-card
        ,input buf_dis-card-property.first-main-card
        ,input buf_dis-card-property.node-code
        ,input integer('99':U)
        ,input p-source-type
        ,input p-source-ref
        ,input-output p-chip-num
        ,input-output p-corr-date
        ,input-output p-corr-time
         ).
    buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U).
    delete buf_dis-card-property no-error .
    if error-status:error then do:
      return error return-value.
    end.
    p-deleted = yes.
  end.
end.
end procedure.
procedure discprop-check :
define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .
define variable v-message as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  if p-host-code > 0 then do:
    FIND FIRST buf_sysconf No-LOCK WHERE
              buf_sysconf.host-code = p-host-code No-ERROR.
    IF NOT AVAIL buf_sysconf THEN DO:
      v-message = substitute("Не найдена фирма &1", p-host-code).
      RETURN ERROR v-message.
    END.
  end.
  if p-obj-type <> "":U or
      p-obj-code <> 0 then do:
    find first buf_clients No-LOCK WHERE
              buf_clients.obj-type = p-obj-type AND
              buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      v-message = substitute("Не найден объект &1&2", p-obj-type, p-obj-code).
      RETURN ERROR v-message.
    end.
  end.
  else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
    v-message = substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                            , p-obj-type
                            , p-obj-code
                            , p-host-code).
    RETURN ERROR v-message.
  end.
  if p-d-card <> "":U then do:
    find first buf_dis-card No-LOCK WHERE
                buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
      v-message =substitute("Не найдена ДК").
      return error  v-message.
    end.
    if buf_dis-card.emitent-host-code <> 0
    and p-host-code <> buf_dis-card.emitent-host-code then do:
      v-message = substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту").
      return error v-message.
    end.
    if buf_dis-card.emitent-host-code = 0
    and p-range = 1
    and p-host-code <> 0 then do:
      v-message = substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                            "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                              , chr(10)
                            ).
      return error v-message.
    end.
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure disdcrul-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disdcrul-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdcrul-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disdcrul-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
end function.
procedure disdcrul-write :
  do
  on error undo, return error
  :
    define input parameter p-d-card         like ub.dis-dc-rule.d-card     no-undo .
    define input parameter p-host-code      like ub.dis-dc-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dc-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dc-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-dc-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dc-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dc-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dc-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dc-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-dc-rule.nonunique   no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-dc-rule for ub.dis-dc-rule .
    define buffer lock_dis-dc-rule for ub.dis-dc-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-dc-rule':U
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
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type12 as character no-undo .
define variable v-value-date12 as date no-undo .
define variable v-value-decimal12 as decimal no-undo .
define variable v-value-integer12 as INTEGER no-undo .
define variable v-value-logical12 AS LOGICAL no-undo .
define variable v-tth12 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date12
    ,output v-value-decimal12
    ,output v-value-integer12
    ,output v-value-logical12
    ,output v-param-type12
    ,INPUT-OUTPUT table-handle v-tth12
    )  .
delete object v-tth12 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не найдено правило скидки &8"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-host-code = buf_dis-rule.host-code
        and p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    then do:
      undo, return error (substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              )
                          +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к ДК для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-dc-rule exclusive-lock where
               buf_dis-dc-rule.d-card  = p-d-card
           AND buf_dis-dc-rule.obj-type  = p-obj-type
           AND buf_dis-dc-rule.host-code = p-host-code
           AND buf_dis-dc-rule.obj-code  = p-obj-code
           AND buf_dis-dc-rule.pos-type  = p-pos-type
           AND buf_dis-dc-rule.discnt-role = p-discnt-role
           and buf_dis-dc-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-dc-rule then do:
      create buf_dis-dc-rule .
      assign
      buf_dis-dc-rule.d-card  = p-d-card
      buf_dis-dc-rule.host-code  = p-host-code
      buf_dis-dc-rule.obj-type  = p-obj-type
      buf_dis-dc-rule.obj-code  = p-obj-code
      buf_dis-dc-rule.pos-type = p-pos-type
      buf_dis-dc-rule.discnt-role = v-discnt-role
      buf_dis-dc-rule.rule-num = p-rule-num
      buf_dis-dc-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-dc-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dc-rule.rule-num = p-rule-num
    buf_dis-dc-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dc-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dc-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
find first buf_c-dc-hist no-lock where
          buf_c-dc-hist.d-card = p-d-card
      AND buf_c-dc-hist.chip-num = p-chip-num
      AND buf_c-dc-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-dc-hist.subject  = p-subject no-error .
if not available buf_c-dc-hist then do:
  return error .
end.
CASE p-subject:
  when 'dis-card':U then do:
    run dis-card-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-obj':U then do:
    run dis-obj-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-host':U then do:
    run dis-host-proc in this-procedure(output p-description) no-error  .
  end.
  when 'dis-card-property':U then do:
    run dis-card-property-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-dc-rule':U then do:
    run dis-dc-rule-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure dis-card-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card for ub.c-dis-card.
  do
  on error undo, return error return-value
  :
    find first current_c-dis-card no-lock where
               current_c-dis-card.d-card = p-d-card
           AND current_c-dis-card.chip-num = p-chip-num
           AND current_c-dis-card.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-dis-card then do:
       v-mess = "Неверная ссылка на c-dis-card в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "card-num" + chr(4) + "Вн № карты" + chr(4) + "" + chr(8)
 + "cash-d-pcnt" + chr(4) + "% скидки на итог" + chr(4) + "" + chr(8)
 + "category" + chr(4) + "Категория" + chr(4) + "" + chr(8)
 + "cli-code" + chr(4) + "Код клиента" + chr(4) + "" + chr(8)
 + "cli-message" + chr(4) + "Сообщ. для клиента" + chr(4) + "" + chr(8)
 + "cli-type" + chr(4) + "Тип клиента" + chr(4) + "" + chr(8)
 + "credit-card" + chr(4) + "Кредитная карта" + chr(4) + "" + chr(8)
 + "d-card" + chr(4) + "№ карты" + chr(4) + "" + chr(8)
 + "d-pcnt" + chr(4) + "Процент скидки" + chr(4) + "" + chr(8)
 + "d-pcnt-method" + chr(4) + "Тип скидки" + chr(4) + "" + chr(8)
 + "debet-card" + chr(4) + "Дебетовая карта" + chr(4) + "" + chr(8)
 + "emitent-host-code" + chr(4) + "Код эмитента" + chr(4) + "" + chr(8)
 + "issue-code" + chr(4) + "Выдал магазин" + chr(4) + "" + chr(8)
 + "issue-date" + chr(4) + "Выдано (дата)" + chr(4) + "" + chr(8)
 + "lim-kr" + chr(4) + "Лимит кредита" + chr(4) + "" + chr(8)
 + "saldo-base" + chr(4) + "Баланс баз вал" + chr(4) + "" + chr(8)
 + "saldo-rubl" + chr(4) + "Баланс нац.вал." + chr(4) + "" + chr(8)
 + "sourced-card" + chr(4) + "Выдано к карте" + chr(4) + "" + chr(8)
 + "staff-card" + chr(4) + "Карта персонала" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "type" + chr(4) + "Тип" + chr(4) + "" + chr(8)
 + "valid-from" + chr(4) + "Начало действия" + chr(4) + "" + chr(8)
 + "valid-date" + chr(4) + "Оконч действия" + chr(4) + "" + chr(8)
 + "first-card" + chr(4) + "Первичная" + chr(4) + "" + chr(8)
 + "first-main-card" + chr(4) + "Первичная основная" + chr(4) + "" + chr(8)
 + "main-card" + chr(4) + "Основная" + chr(4) + "" + chr(8)
 + "is-subsid" + chr(4) + "Дополн?" + chr(4) + "" + chr(8)
 + "overissue-num" + chr(4) + "Пор-к в цепочке перевыпуска" + chr(4) + "" + chr(8)
 + "service-db-num" + chr(4) + "Обслуживающая БД" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer('1':U))
                                            ,input  (buf_c-dc-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-card:handle
                                            ,input  'dis-card':U
                                            ,input  "card-num,cash-d-pcnt,category,cli-code,cli-message,cli-type,credit-card,d-card,d-pcnt,d-pcnt-method,debet-card,emitent-host-code,issue-code,issue-date,lim-kr,saldo-base,saldo-rubl,sourced-card,staff-card,status_,type,valid-date,first-card,first-main-card,main-card,is-subsid,overissue-num,service-db-num"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-card-property-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-mess as character no-undo .
define buffer current_c-dis-card-property for ub.c-dis-card-property  .
do
on error undo, return error return-value
:
    find first current_c-dis-card-property no-lock where
               current_c-dis-card-property.d-card = p-d-card
           AND current_c-dis-card-property.chip-num = p-chip-num
           AND current_c-dis-card-property.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-dis-card-property then do:
       v-mess = "Неверная ссылка на c-dis-card-property в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
    end.
    run discprop-node-name in this-procedure ( input substitute("&1&2&3"
                                                                ,current_c-dis-card-property.dtm-code
                                                                , chr(4)
                                                                ,current_c-dis-card-property.node-code)
                                          ,output v-tooltip
                                          ,output v-label
                                          ) no-error .
    assign
    p-description = "Свойство" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "d-card" + chr(4) + "№ карты" + chr(4) + "" + chr(8)
 + "dt-code" + chr(4) + "Код среза" + chr(4) + "" + chr(8)
 + "sum-id" + chr(4) + "ID среза" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "property-value-character" + chr(4) + "Значение(строковое)" + chr(4) + "" + chr(8)
 + "property-value-date" + chr(4) + "Значение(дата)" + chr(4) + "" + chr(8)
 + "property-value-decimal" + chr(4) + "Значение(десятичное)" + chr(4) + "" + chr(8)
 + "property-value-integer" + chr(4) + "Значение(целое)" + chr(4) + "" + chr(8)
 + "property-value-logical" + chr(4) + "Значение(логическое)" + chr(4) + "" + chr(8)
 + "dtm-code" + chr(4) + "Код объекта-операнда" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer('1':U))
                                            ,input  (buf_c-dc-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-card-property:handle
                                            ,input  'dis-card-property':U
                                            ,input  "d-card,dt-code,sum-id,host-code,obj-type,obj-code,property-value-character,property-value-date,property-value-decimal,property-value-integer,property-value-logical,dtm-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-obj-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-obj for ub.c-dis-obj  .
  do
  on error undo, return error return-value
  :
    find first current_c-dis-obj no-lock where
              current_c-dis-obj.d-card  = p-d-card
          and current_c-dis-obj.corr-user-db-num = p-corr-user-db-num
          and current_c-dis-obj.chip-num = p-chip-num no-error.
    if not available current_c-dis-obj then do:
      v-mess = "Неверная ссылка на c-dis-obj в таблице c-dc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
    if current_C-DIS-OBJ.dt-code > 0  THEN
    assign
    p-description = substitute("Частные итоги: &1", dct-algo-get-description-sum-id(current_c-dis-obj.dt-code))
    .
define variable v-label-param as character no-undo .
v-label-param =
  "card-num" + chr(4) + "Вн № карты" + chr(4) + "" + chr(8)
 + "gds-dis-base" + chr(4) + "Скидка тов. - баз вал." + chr(4) + "" + chr(8)
 + "gds-dis-rubl" + chr(4) + "Скидка тов. - нац.вал." + chr(4) + "" + chr(8)
 + "gds-tot-b0" + chr(4) + "Сум. тов. в учет. ценах баз вал." + chr(4) + "" + chr(8)
 + "gds-tot-base" + chr(4) + "Сум. тов. в ценах продажи баз вал." + chr(4) + "" + chr(8)
 + "gds-tot-r0" + chr(4) + "Сум. тов. в учет. ценах нац.вал." + chr(4) + "" + chr(8)
 + "gds-tot-rubl" + chr(4) + "Сум. тов. в ценах продажи нац.вал." + chr(4) + "" + chr(8)
 + "sum-dis-base" + chr(4) + "Скидка итоговая в баз.вал." + chr(4) + "" + chr(8)
 + "sum-dis-rubl" + chr(4) + "Скидка итоговая в нац.вал." + chr(4) + "" + chr(8)
 + "sum-tot-base" + chr(4) + "Суммовые строки" + chr(4) + "" + chr(8)
 + "sum-tot-rubl" + chr(4) + "Суммовые строки" + chr(4) + "" + chr(8)
 + "num-chk" + chr(4) + "Число чеков" + chr(4) + "" + chr(8)
 + "pay-tot-base" + chr(4) + "Сум. плат. баз вал." + chr(4) + "" + chr(8)
 + "pay-tot-rubl" + chr(4) + "Сум. плат. нац.вал." + chr(4) + "" + chr(8)
 + "dt-code" + chr(4) + "№ частного итога" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer('1':U))
                                            ,input  (buf_c-dc-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-obj:handle
                                            ,input  'dis-obj':U
                                            ,input  "card-num,gds-dis-base,gds-dis-rubl,gds-tot-b0,gds-tot-base,gds-tot-r0,gds-tot-rubl,sum-dis-base,sum-dis-rubl,sum-tot-base,sum-tot-rubl,num-chk,pay-tot-base,pay-tot-rubl,dt-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-host-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-host for ub.c-dis-host  .
  do
  on error undo, return error return-value
  :
    find first current_c-dis-host no-lock where
              current_c-dis-host.d-card  = p-d-card
          and current_c-dis-host.corr-user-db-num = p-corr-user-db-num
          and current_c-dis-host.chip-num = p-chip-num no-error.
    if not available current_c-dis-host then do:
      v-mess = "Неверная ссылка на c-dis-host в таблице c-dc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
    if current_C-DIS-host.dt-code > 0  THEN
    assign
    p-description = substitute("Частные итоги: &1", dct-algo-get-description-sum-id(current_c-dis-host.dt-code))
    .
define variable v-label-param as character no-undo .
v-label-param =
  "card-num" + chr(4) + "Вн № карты" + chr(4) + "" + chr(8)
 + "gds-dis-base" + chr(4) + "Скидка тов. - баз вал." + chr(4) + "" + chr(8)
 + "gds-dis-rubl" + chr(4) + "Скидка тов. - нац.вал." + chr(4) + "" + chr(8)
 + "gds-tot-base" + chr(4) + "Сум. тов. в ценах продажи баз вал." + chr(4) + "" + chr(8)
 + "gds-tot-rubl" + chr(4) + "Сум. тов. в ценах продажи нац.вал." + chr(4) + "" + chr(8)
 + "sum-dis-base" + chr(4) + "Скидка итоговая в баз.вал." + chr(4) + "" + chr(8)
 + "sum-dis-rubl" + chr(4) + "Скидка итоговая в баз.вал." + chr(4) + "" + chr(8)
 + "sum-tot-base" + chr(4) + "Суммовые строки" + chr(4) + "" + chr(8)
 + "sum-tot-rubl" + chr(4) + "Суммовые строки" + chr(4) + "" + chr(8)
 + "num-chk" + chr(4) + "Число чеков" + chr(4) + "" + chr(8)
 + "pay-tot-base" + chr(4) + "Сум. плат. баз.вал." + chr(4) + "" + chr(8)
 + "pay-tot-rubl" + chr(4) + "Сум. плат. нац.вал." + chr(4) + "" + chr(8)
 + "dt-code" + chr(4) + "№ частного итога" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer('1':U))
                                            ,input  (buf_c-dc-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-host:handle
                                            ,input  'dis-host':U
                                            ,input  "card-num,gds-dis-base,gds-dis-rubl,gds-tot-base,gds-tot-rubl,sum-dis-base,sum-dis-rubl,sum-tot-base,sum-tot-rubl,num-chk,pay-tot-base,pay-tot-rubl,dt-code"
                                            ,input  v-label-param).
  end.
end procedure.
procedure dis-dc-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-dc-rule for ub.c-dis-dc-rule  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-dis-dc-rule no-lock where
               current_c-dis-dc-rule.d-card = p-d-card
           AND current_c-dis-dc-rule.chip-num = p-chip-num
           AND current_c-dis-dc-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    if not avail current_c-dis-dc-rule then do:
       v-mess = "Неверная ссылка на c-dis-dc-rule в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disdcrul-name in this-procedure (
                input  current_c-dis-dc-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .
define variable v-label-param as character no-undo .
v-label-param =
  "rule-num" + chr(4) + "Номер правила скидки" + chr(4) + "" + chr(8)
 + "pos-type" + chr(4) + "Место использ." + chr(4) + "" + chr(8)
 + "templ-rl-root" + chr(4) + "Шаблон скидки" + chr(4) + "disdcrul-get-disc-label"  + chr(8)
 + "discnt-role" + chr(4) + "Тип скидки" + chr(4) + "disdcrul-get-disc-role-label"  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer('1':U))
                                            ,input  (buf_c-dc-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-dc-rule:handle
                                            ,input  'dis-dc-rule':U
                                            ,input  "rule-num,pos-type,templ-rl-root,discnt-role"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("История контрагента  &1&2: щепка &3 БД:&4 фирма: &5  Предмет изменений &6&7&8"
                          ,p-obj-type
                          , p-obj-code
                          , p-chip-num
                          , p-corr-user-db-num
                          , p-host-code
                          , p-subject
                          ,chr(10)
                          ,p-mess
                          ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
