block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-layout-id as character no-undo .
define input parameter        p-layout-type as character no-undo .
define input parameter        p-device-type as character no-undo .
define input parameter        p-layout-name as character no-undo .
define input parameter        p-is-default as integer no-undo .
define input  parameter       p-des as character no-undo .
define temp-table tt-rule-by-call no-undo like ub.rule-by-call.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-by-call.
define temp-table tt-layout-elem-rule no-undo like ub.layout-elem-rule.
DEFINE INPUT PARAMETER TABLE FOR tt-layout-elem-rule.
define temp-table tt-rule-call-param no-undo like ub.rule-call-param.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-call-param.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layout1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layout1.p $":U .
define variable vss-description as character no-undo init "Сохранение раскладки".
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
procedure layouth_create-layout_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define parameter buffer buf_layout for ub.layout.
define output parameter p-chip-num as integer no-undo .
define variable v-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout for ub.c-layout.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  find last buf_c-layout no-lock where
            buf_c-layout.layout-id = p-layout-id
       and  buf_c-layout.corr-user-db-num = g#db-num
       use-index pi no-error.
  assign
  v-chip-num = (if available buf_c-layout
                then buf_c-layout.chip-num + 1
                else 0).
  create buf_c-layout.
  if available buf_layout
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout
    to buf_c-layout.
  end.
  if not available buf_layout then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  assign
  buf_c-layout.subject = 'layout':U
  buf_c-layout.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout.chip-num = v-chip-num
  buf_c-layout.corr-user-db-num = g#db-num
  buf_c-layout.corr-user-name = g#userid
  buf_c-layout.corr-date = v-today
  buf_c-layout.corr-time = v-time
  p-chip-num = v-chip-num
  .
end.
end procedure.
procedure layouth_create-layout-elem-rule_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define input parameter p-mode-id as character no-undo .
define input parameter p-widget-id as character no-undo .
define parameter buffer buf_layout-elem-rule for ub.layout-elem-rule.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-layout-elem-rule.
  if available buf_layout-elem-rule
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout-elem-rule
    to buf_c-layout-elem-rule.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout-elem-rule.layout-id = p-layout-id
    buf_c-layout-elem-rule.mode-id = p-mode-id
    buf_c-layout-elem-rule.widget-id = p-widget-id
    .
  end.
  assign
  buf_c-layout-elem-rule.subject = 'layout-elem-rule':U
  buf_c-layout-elem-rule.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout-elem-rule.chip-num = p-chip-num
  buf_c-layout-elem-rule.corr-user-db-num = g#db-num
  buf_c-layout-elem-rule.corr-user-name = g#userid
  buf_c-layout-elem-rule.corr-date = v-today
  buf_c-layout-elem-rule.corr-time = v-time
  .
end.
end procedure.
procedure layouth_create-rule-call-param_h :
define input parameter p-mode as character no-undo .
define input parameter p-call#-id as integer no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-index as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-rule-call-param.
  if available buf_rule-call-param
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_rule-call-param
    to buf_c-rule-call-param.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-rule-call-param.call#_id = p-call#-id
    buf_c-rule-call-param.codex_id = p-codex-id
    buf_c-rule-call-param.ruleset_id = p-ruleset-id
    buf_c-rule-call-param.order_id = p-order-id
    buf_c-rule-call-param.param-name = p-param-name
    buf_c-rule-call-param.p-index = p-index
    buf_c-rule-call-param.call_id = p-call-id
    .
  end.
  assign
  buf_c-rule-call-param.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                  then integer('1':U)
                                  else (if p-mode = 'удаление':U
                                        then integer('99':U)
                                        else integer('2':U)
                                        )
                                  )
  buf_c-rule-call-param.chip-num = p-chip-num
  buf_c-rule-call-param.corr-user-db-num = g#db-num
  buf_c-rule-call-param.corr-user-name = g#userid
  buf_c-rule-call-param.corr-date = v-today
  buf_c-rule-call-param.corr-time = v-time
  .
end.
end procedure.
define variable v-admin as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
define variable v-last-id-int as integer no-undo .
define variable v-layout-id as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rbc-uniq-key-rec as character no-undo .
define variable v-call#-id as integer no-undo .
define variable v-cmp as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_layout for ub.layout.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_layout-elem  for ub.layout-elem.
define buffer buf2_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule for ub.rule.
if lookup('admin', p-mode) > 0 then do:
  v-admin = yes.
  p-mode = trim(replace(p-mode, 'admin', ''), chr(44)).
end.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0
and (p-is-default = integer('1':U)
     or
     p-is-default = integer('-1':U))
then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено в УБД редактировать дефолтные и обязательные раскладки"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_layout
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if lookup(string(p-is-default), '0,1,-1':U) = 0 then do:
    assign
    v-mess = substitute("Неверное значение параметра p-is-default=&1", p-is-default).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'is-default':U).
  end.
  if p-layout-name = '' then do:
    assign
    v-mess = substitute("Не задано название раскладки").
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'layout-name':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-is-default = integer('0':U) then do:
      v-last-id-int = next-value(s-layout-id, ub).
      if g#db-num = 0 then do:
        v-layout-id = substitute("&1", string(v-last-id-int)).
      end.
      else do:
        v-layout-id = substitute("&1-&2", string(v-last-id-int), g#db-num).
      end.
    end.
    else do:
      if p-is-default = integer('-1':U) then do:
        if can-find(first ub.layout no-lock where
                         ub.layout.layout-type = p-layout-type
                      and ub.layout.device-type = p-device-type) then do:
          assign
          v-mess = substitute("Уже существует обязательная раскладка с типом &1 для &2"
                             , p-layout-type
                             , p-device-type
                             ).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
     _do:
      do v-ii = 9 to 1 by -1:
        find last buf_layout no-lock where
               buf_layout.layout-id >= substitute("_1&1"
                                                   ,fill("0", v-ii - 1)
                                                   )
             and buf_layout.layout-id <= substitute("_&1"
                                                   ,fill("9", v-ii)
                                                   )
                 no-error.
        if available buf_layout then do:
          v-last-id-int = integer(left-trim(entry(1, buf_layout.layout-id), "_")).
          leave _do.
        end.
        else do:
          next _do.
        end.
      end.
      v-layout-id = substitute("_&1", string(v-last-id-int + 1)).
    end.
    find first buf_layout no-lock where
              buf_layout.layout-id = v-layout-id no-error .
    if available buf_layout then do:
      assign
      v-mess = substitute("Уже существует раскладка c id = &1", v-layout-id).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if lookup( entry(1, p-layout-type, "_") , 'th-pos-screen,th-pos-keyboard':U) = 0 then do:
      assign
      v-mess = substitute("Неверный тип раскладки &1", p-layout-type).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else 'layout-type':U).
    end.
    case p-layout-type:
      WHEN 'th-pos-keyboard':U  THEN DO:
        if lookup(p-device-type, 'IBM-50':U) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else 'device-type':U).
        end.
      END.
      WHEN 'th-pos-screen':U  THEN DO:
        if lookup(p-device-type, 'Screen,TouchScreen':U) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else 'device-type':U).
        end.
      END.
    end case.
    create buf_layout.
    assign
    buf_layout.layout-type = p-layout-type
    buf_layout.layout-id = v-layout-id
    buf_layout.device-type = p-device-type
    buf_layout.des = p-des
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    v-layout-id = p-layout-id.
    find first buf_layout exclusive-lock where
              recid(buf_layout) = p-rec .
    if buf_layout.layout-type <> p-layout-type
    or buf_layout.device-type <> p-device-type
    or buf_layout.layout-id <> p-layout-id
    then do:
      assign
      v-mess = substitute("Для уже существующей расладки невозможно измененить тип раскладки, тип устройства, идентификатор раскладки&1"
                              , chr(10)
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  run  layouth_create-layout_h  in this-procedure (
                                                  input p-mode
                                                 ,input v-layout-id
                                                 ,buffer buf_layout
                                                 ,output v-chip-num).
  assign
  buf_layout.is-default = p-is-default
  buf_layout.layout-name = p-layout-name
  p-rec = recid(buf_layout)
  .
  if p-is-default = integer('0':U)
  or p-is-default = integer('1':U)
  then do:
    find first buf2_layout share-lock where
              buf2_layout.layout-type = p-layout-type
          and buf2_layout.device-type = p-device-type
          and buf2_layout.is-default = integer('-1':U) no-error.
  end.
  for each buf_tt-layout-elem-rule:
    find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = 'cd-IBS-TH':U
          and buf_wi-mode.mode-id = buf_tt-layout-elem-rule.mode-id no-error.
    if not available buf_wi-mode then do:
      v-mess = substitute("Не найден режим &1 для элемента раскладки &2"
                          , buf_tt-layout-elem-rule.mode-id
                          , buf_tt-layout-elem-rule.widget-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
     find first buf_layout-elem no-lock where
              buf_layout-elem.layout-type = p-layout-type
          and buf_layout-elem.device-type = p-device-type
          and buf_layout-elem.mode-id = buf_tt-layout-elem-rule.mode-id
          and buf_layout-elem.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
    if not available buf_layout-elem then do:
      v-mess = substitute("Не найден элемент раскладки &1 для режима &2"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_layout-elem.elem-type = integer('-1':U) then do:
      v-mess = substitute("Элемент раскладки &1 для режима &2 является НЕПРОГРАММИРУЕМЫМ"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if available buf2_layout then do:
      find first buf2_layout-elem-rule no-lock where
                buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
            and buf2_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
            and buf2_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
      if available buf2_layout-elem-rule
      and buf2_layout-elem-rule.rule_id <> buf_tt-layout-elem-rule.rule_id then do:
        find first buf_rule no-lock where buf_rule.rule_id = buf2_layout-elem-rule.rule_id no-error.
        v-mess = substitute("Элемент раскладки &1 для режима &2 является ОБЯЗАТЕЛЬНЫМ&3с привязанным к нему правилом &4"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                          , chr(10)
                          , (if available buf_rule then buf_rule.name else string(buf2_layout-elem-rule.rule_id))
                                                    ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    find first buf_tt-rule-by-call where
              buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec no-error .
    if not available buf_tt-rule-by-call then do:
      message
      substitute("Внутренняя ошибка - не найдена точка вызова для &1", buf_tt-layout-elem-rule.uniq-key-rec)
      view-as alert-box error .
      undo _main, return error .
    end.
    assign
    buf_tt-layout-elem-rule.layout-id = v-layout-id.
    run gen-key-rec in this-procedure ( input 'layout-elem-rule':U
                                        ,input (buffer  buf_tt-layout-elem-rule:handle)
                                        ,output v-uniq-key-rec).
    for each buf_tt-rule-call-param where
            buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
        and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
        and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
        and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id:
      assign
      buf_tt-rule-call-param.call_id = v-uniq-key-rec.
    end.
    assign
    buf_tt-layout-elem-rule.uniq-key-rec = v-uniq-key-rec
    buf_tt-rule-by-call.call_id = v-uniq-key-rec
    .
  end.
  for each buf2_layout-elem-rule no-lock where
          buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
  on error  undo, return error:
    find first buf_tt-layout-elem-rule where
              buf_tt-layout-elem-rule.layout-id = v-layout-id
        and buf_tt-layout-elem-rule.mode-id = buf2_layout-elem-rule.mode-id
        and buf_tt-layout-elem-rule.widget-id = buf2_layout-elem-rule.widget-id no-error.
    if not available buf_tt-layout-elem-rule
    or buf_tt-layout-elem-rule.rule_id <> buf2_layout-elem-rule.rule_id then do:
      v-mess = substitute("Не найден ОБЯЗАТЕЛЬНЫЙ элемент раскладки &1 для режима &2"
                          , buf2_layout-elem-rule.mode-id
                          , buf2_layout-elem-rule.widget-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    assign
    buf_tt-layout-elem-rule.is-mandatory = integer('1':U)
    .
  end.
  for each buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.layout-id = v-layout-id
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-rule-by-call where
              buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec.
     find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = 'cd-IBS-TH':U
          and buf_wi-mode.mode-id = buf_tt-layout-elem-rule.mode-id no-error.
     if not available buf_wi-mode then do:
       v-mess = substitute("Не найден режим работы &1", buf_tt-layout-elem-rule.mode-id).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
     end.
     find first buf_rule-by-call share-lock where
              buf_rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
          and buf_rule-by-call.codex_id = buf_wi-mode.codex_id
          and buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
          and buf_rule-by-call.order_id = 0 no-error.
     v-cmp = yes.
     if not available buf_rule-by-call then do:
       run rul/g-callid.p (
                           input (if p-is-default = integer('0':U)
                                  then 'layout-elem-rule':U
                                  else 'layout-elem-rule':U + chr(44) + "minus")
                          ,input buf_tt-layout-elem-rule.uniq-key-rec
                          ,output v-call#-id).
       create buf_rule-by-call.
       assign
       buf_rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       buf_rule-by-call.call#_id = v-call#-id
       buf_rule-by-call.codex_id = buf_wi-mode.codex_id
       buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
       buf_rule-by-call.order_id = 0
       .
       run gen-key-rec in this-procedure ( input 'rule-by-call':U
                                          ,input (buffer  buf_rule-by-call:handle)
                                          ,output v-rbc-uniq-key-rec).
       buf_rule-by-call.uniq-key-rec = v-rbc-uniq-key-rec.
       v-cmp = no.
     end.
     else do:
       buffer-compare buf_rule-by-call to buf_tt-rule-by-call
       case-sensitive
       save result in v-cmp.
       v-call#-id = buf_rule-by-call.call#_id.
     end.
     if not v-cmp then do:
       buffer-copy buf_tt-rule-by-call
       except call_id call#_id codex_id ruleset_id uniq-key-rec
       to buf_rule-by-call.
     end.
     v-cmp = yes.
     find first buf_layout-elem-rule share-lock where
              buf_layout-elem-rule.layout-id = v-layout-id
          and buf_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
          and buf_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
     if not available buf_layout-elem-rule then do:
       create buf_layout-elem-rule.
       assign
       buf_layout-elem-rule.layout-id = v-layout-id
       v-cmp = no.
     end.
     else do:
        buffer-compare buf_layout-elem-rule to buf_tt-layout-elem-rule
        case-sensitive
        save result in v-cmp.
     end.
     if not v-cmp then do:
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input (if new(buf_layout-elem-rule)
                                                               then 'ДОБАВЛЕНИЕ':U
                                                               else 'ИЗМЕНЕНИЕ':U)
                                                      ,input buf_tt-layout-elem-rule.layout-id
                                                      ,input buf_tt-layout-elem-rule.mode-id
                                                      ,input buf_tt-layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
       buffer-copy buf_tt-layout-elem-rule
       except layout-id cr-db-num
       to buf_layout-elem-rule.
     end.
     for each buf_tt-rule-call-param where
              buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-call-param share-lock where
              buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
          and buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index no-error.
      if not available(buf_rule-call-param) then do:
       create buf_rule-call-param.
       assign
       buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
       buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
       buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
       buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
       buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
       buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index
       buf_rule-call-param.call#_id = v-call#-id
       v-cmp = no
       .
      end.
      else do:
         buffer-compare buf_rule-call-param to buf_tt-rule-call-param
         case-sensitive
         save result in v-cmp.
      end.
      if not v-cmp then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input (if new(buf_rule-call-param)
                                                               then 'ДОБАВЛЕНИЕ':U
                                                               else 'ИЗМЕНЕНИЕ':U)
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_tt-rule-call-param.codex_id
                                                      ,input buf_tt-rule-call-param.ruleset_id
                                                      ,input buf_tt-rule-call-param.order_id
                                                      ,input buf_tt-rule-call-param.param-name
                                                      ,input buf_tt-rule-call-param.p-index
                                                      ,input buf_tt-rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        buffer-copy buf_tt-rule-call-param
        except call_id call#_id codex_id ruleset_id order_id param-name p-index
        to buf_rule-call-param.
      end.
    end.
     for each buf_rule-call-param where
              buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        find first buf_tt-rule-call-param share-lock where
              buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id
          and buf_tt-rule-call-param.param-name = buf_rule-call-param.param-name
          and buf_tt-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
      if not available(buf_tt-rule-call-param) then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input 'удаление':U
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        delete buf_rule-call-param.
      end.
    end.
  end.
  for each buf_layout-elem-rule share-lock where
          buf_layout-elem-rule.layout-id = v-layout-id
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
     find first buf_tt-layout-elem-rule where
              buf_tt-layout-elem-rule.layout-id = buf_layout-elem-rule.layout-id
          and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
          and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
    if not available buf_tt-layout-elem-rule then do:
      find first buf_rule-by-call share-lock where
                buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec no-error.
      for each buf_rule-call-param where
                buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input 'удаление':U
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        delete buf_rule-call-param.
      end.
      if available buf_rule-by-call then do:
        delete buf_rule-by-call.
      end.
      run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                      input 'удаление':U
                                                    ,input buf_layout-elem-rule.layout-id
                                                    ,input buf_layout-elem-rule.mode-id
                                                    ,input buf_layout-elem-rule.widget-id
                                                    ,buffer buf_layout-elem-rule
                                                    ,input v-chip-num).
      delete buf_layout-elem-rule.
    end.
  end.
  find first buf_layout-elem-rule no-lock where
           buf_layout-elem-rule.layout-id = buf_layout.layout-id
       and buf_layout-elem-rule.sts <> integer('0':U) no-error.
  if not available buf_layout-elem-rule
  and buf_layout.sts <> integer('99':U)
  then do:
    buf_layout.sts = integer('0':U).
  end.
  assign
  buf_layout.whole-send-news = 1
  .
  release buf_layout no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении шапки раскладки:&1&2&1&3"
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Раскладка: тип &1 id &2 для устройства &3:&4&5"
                         , p-layout-type
                         , p-layout-id
                         , p-device-type
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
