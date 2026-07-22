DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-rule-call-param.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 73".
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-param-value RETURNS CHARACTER
  ( INPUT p-data-type AS CHARACTER
   ,INPUT p-2-data-type AS character
   ,INPUT p-3-data-type AS CHARACTER
   ,INPUT p-p-index AS INTEGER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
     ) :
define buffer buf_cash-pay for ub.cash-pay.
define variable v-view-value as character no-undo .
if (p-3-data-type = "LIST"
     or
     p-3-data-type = "SORTED-LIST"
     )
and p-p-index = 0 then return '':U.
if p-2-data-type > '' then do:
  case p-2-data-type:
    when 'cash-pay':U
    or
    when 'cash-pay':U + "_null"
    then do:
      if p-2-data-type = 'cash-pay':U + "_null"
      and p-value-character = substitute("&1,&2", 0, 0) then return "Тип касс. платежа не задан".
      else do:
        find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
              and buf_cash-pay.curr-code = integer(entry(2, p-value-character)) no-error.
        if available buf_cash-pay then return buf_cash-pay.obj-name.
        else return "!!!Неизвестный тип касс.платежа".
      end.
    end.
    when 'chk-doc':U + "_wth-type_null"
    or when 'chk-doc':U + "_wth-type" then do:
      return entry (lookup (string(p-value-integer),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U).
    end.
    when 'discnt-v-type-manual':U then do:
            return entry (lookup (string(p-value-integer), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U).
    end.
    otherwise do:
      if lookup(p-2-data-type, 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U) > 0  then do:
         if lookup(p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
         end.
         if lookup(p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u).
         end.
         if lookup(p-value-character, 'simple-pay,qnty-pay':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u).
         end.
         if lookup(p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
         end.
         if lookup(p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u).
         end.
         if lookup(p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u).
         end.
         if lookup(p-value-character, 'cli-grp-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'cli-grp-pcnt':u) + 1, ',' + '% скидка на группу клиентов':u).
         end.
      end.
    end.
  end case.
end.
case p-data-type:
  when 'character':U then do:
    return p-value-character.
  end.
  when 'date':U then do:
    return string(p-value-date, "99/99/9999").
  end.
  when 'decimal':U then do:
    return string(p-value-decimal).
  end.
  when 'integer':U then do:
    return string(p-value-integer).
  end.
  when 'logical':U then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-ch AS WIDGET-HANDLE NO-UNDO EXTENT 6.
DEFINE VARIABLE v-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rp-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rcps-entry-id AS INTEGER NO-UNDO.
DEFINE VARIABLE v-uniq-key-rec AS character NO-UNDO.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_Rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_Ruledict FOR ub.ruledict.
DEFINE BUFFER call_tt-rule-call-param FOR tt-rule-call-param.
define buffer term_tt-rule-call-param for tt-rule-call-param.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rcps_get-profile-id :
define output parameter p-local-profile-id as integer no-undo .
do
on error undo, return error:
p-local-profile-id = p-profile-id.
end.
end procedure.
PROCEDURE rcps_fill-table :
define input parameter p-clear-params as logical no-undo .
if p-clear-params then do:
FOR EACH tt-rule-call-param:
    DELETE tt-rule-call-param.
END.
end.
 FOR EACH tt0-rule-call-param:
   IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
   END.
   if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then do:
     next.
   end.
   IF p-list-mode = 'rp-rule-param':U
   or p-list-mode = 'rp-rule-param':U  + chr(44) + 'все':U
   THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
   END.
   CREATE tt-rule-call-param.
   BUFFER-COPY tt0-rule-call-param TO tt-rule-call-param.
END.
END PROCEDURE.
procedure rcps_get-value :
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER pp-index AS integer NO-UNDO.
DEFINE output parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE output parameter p-value-date AS date NO-UNDO.
DEFINE output parameter p-value-decimal AS decimal NO-UNDO.
DEFINE output parameter p-value-integer AS integer NO-UNDO.
DEFINE output parameter p-value-logical AS logical NO-UNDO.
define variable v-current-index as integer no-undo init -1.
define variable v-start as logical no-undo init yes.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_term_tt-rule-call-param FOR tt-rule-call-param.
do
on error undo, return error
:
FOR FIRST buf_rp-rule-param WHERE
      buf_rp-rule-param.profile_id = p-profile-id
  AND buf_rp-rule-param.rp-param-name = p-rp-param-name
, each buf_tt-rule-call-param WHERE
   buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
AND buf_tt-rule-call-param.p-index >= pp-index
 ,each buf_term_tt-rule-call-param where
       buf_term_tt-rule-call-param.call_id = buf_tt-rule-call-param.call_id
   and buf_term_tt-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
   and buf_term_tt-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
   and buf_term_tt-rule-call-param.order_id = buf_tt-rule-call-param.order_id
   and buf_term_tt-rule-call-param.param-name = buf_tt-rule-call-param.param-name
   and buf_term_tt-rule-call-param.p-index = buf_tt-rule-call-param.p-index
  by buf_term_tt-rule-call-param.call_id
  by buf_term_tt-rule-call-param.codex_id
  by buf_term_tt-rule-call-param.ruleset_id
  by buf_term_tt-rule-call-param.order_id
  by buf_term_tt-rule-call-param.param-name
  by buf_term_tt-rule-call-param.p-index :
    if v-start
    then do:
      assign
      pp-index = buf_term_tt-rule-call-param.p-index
      p-value-character = buf_term_tt-rule-call-param.param-value-character
      p-value-date      = buf_term_tt-rule-call-param.param-value-date
      p-value-decimal   = buf_term_tt-rule-call-param.param-value-decimal
      p-value-integer   = buf_term_tt-rule-call-param.param-value-integer
      p-value-logical   = buf_term_tt-rule-call-param.param-value-logical
      v-start = no
      .
    end.
    else do:
      if buf_term_tt-rule-call-param.p-index > pp-index then do:
        v-current-index = buf_term_tt-rule-call-param.p-index.
        leave.
      end.
          end.
  end.
  pp-index = v-current-index.
end.
end procedure.
PROCEDURE rcps_proc-b-add :
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = p-index:
  RETURN.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF buf0_tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
find last buf_tt-rule-call-param where
         buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
     and buf_tt-rule-call-param.codex_id = buf0_tt-rule-call-param.codex_id
     and buf_tt-rule-call-param.ruleset_id = buf0_tt-rule-call-param.ruleset_id
     and buf_tt-rule-call-param.order_id = buf0_tt-rule-call-param.order_id
     and buf_tt-rule-call-param.param-name = buf0_tt-rule-call-param.param-name no-error .
if available buf_tt-rule-call-param
and (lookup("LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     or
     lookup("SORTED-LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     )
and buf_tt-rule-call-param.p-index > 0 then do:
  v-ind = buf_tt-rule-call-param.p-index.
end.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = 0
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  create buf2_tt-rule-call-param.
  buffer-copy buf_tt-rule-call-param
  except p-index
  to buf2_tt-rule-call-param
  assign
  buf2_tt-rule-call-param.p-index = v-ind + 1
  .
end.
END PROCEDURE.
PROCEDURE rcps_proc-b-del :
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define variable v-once-more as integer no-undo .
define variable v-call-id as character no-undo .
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
if pp-index = 0 then do:
  undo, return error substitute("Нельзя удалять корневой параметр &1 (индекс = 0)", p-rp-param-name).
end.
FOR first buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
   AND buf0_tt-rule-call-param.p-index = pp-index
   :
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  FOR first buf_rp-rule-param WHERE
            buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
      , last buf0_tt-rule-call-param WHERE
        buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    AND buf0_tt-rule-call-param.p-index > pp-index :
    leave.
  end.
  IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  return "not-found".
  end.
  else do:
    return ''.
  end.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  undo, return error substitute("Можно удалять только параметры типа LIST и SORTED-LIST").
END.
IF lookup("READ-ONLY", buf0_tt-rule-call-param.param-3-data-type) > 0 THEN DO:
  undo, return error substitute("Нельзя удалять  параметры типа READ-ONLY").
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = buf_rp-rule-param.profile_id,
    each buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = p-call-id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = p-once-more
    and buf_tt-rule-call-param.p-index = pp-index
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile ):
    DELETE buf_tt-rule-call-param.
end.
return ''.
END PROCEDURE.
PROCEDURE rcps_proc-save0 :
FOR EACH tt-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
   find  FIRST tt0-rule-call-param NO-LOCK WHERE
            tt0-rule-call-param.codex_id = tt-rule-call-param.codex_id
       AND  tt0-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
       AND tt0-rule-call-param.call_id = tt-rule-call-param.call_id
       AND tt0-rule-call-param.order_id = tt-rule-call-param.order_id
       AND tt0-rule-call-param.param-name = tt-rule-call-param.param-name
       AND tt0-rule-call-param.p-index = tt-rule-call-param.p-index no-error .
   if not available tt0-rule-call-param
   and (lookup("LIST", tt-rule-call-param.param-3-data-type) > 0
        OR
        lookup("SORTED-LIST", tt-rule-call-param.param-3-data-type) > 0
        )
   and tt-rule-call-param.p-index > 0 then do:
     create tt0-rule-call-param.
   end.
   BUFFER-COPY tt-rule-call-param TO tt0-rule-call-param.
END.
FOR EACH tt0-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-call-param.p-index = 0 then next.
  if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then next.
  find  FIRST tt-rule-call-param NO-LOCK WHERE
          tt-rule-call-param.codex_id = tt0-rule-call-param.codex_id
      AND tt-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
      AND tt-rule-call-param.call_id = tt0-rule-call-param.call_id
      AND tt-rule-call-param.order_id = tt0-rule-call-param.order_id
      AND tt-rule-call-param.param-name = tt0-rule-call-param.param-name
      AND tt-rule-call-param.p-index = tt0-rule-call-param.p-index no-error .
  if not available tt-rule-call-param
  and (lookup("LIST", tt0-rule-call-param.param-3-data-type) > 0
      OR
      lookup("SORTED-LIST", tt0-rule-call-param.param-3-data-type) > 0
      )
  and tt0-rule-call-param.p-index > 0
  then do:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
    IF p-list-mode = 'rp-rule-param':U
    or p-list-mode = 'rp-rule-param':U  + chr(44) + 'все':U
    THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
    end.
    delete tt0-rule-call-param.
  end.
end.
END PROCEDURE.
PROCEDURE rcps_set-value :
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-codex-id AS integer NO-UNDO.
DEFINE VARIABLE v-ruleset-id AS integer NO-UNDO.
DEFINE VARIABLE v-order-id AS integer NO-UNDO.
DEFINE VARIABLE V-param-name AS character NO-UNDO.
define variable v-found as logical no-undo .
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf_tt-rule-call-param WHERE
       buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  ASSIGN
  v-codex-id = buf_tt-rule-call-param.codex_id
  v-ruleset-id = buf_tt-rule-call-param.ruleset_id
  v-order-id = buf_tt-rule-call-param.order_id
  V-PARAM-NAME = buf_tt-rule-call-param.PARAM-NAME
  .
  LEAVE.
END.
CASE p-list-mode:
  WHEN 'rp-rule-param':U THEN DO:
    if pp-index > 0
    then do:
      FOR EACH  buf_rp-rule-param NO-LOCK where
          buf_rp-rule-param.profile_id = p-profile-id
          AND buf_rp-rule-param.rp-param-name = p-rp-param-name
          ,EACH buf_tt-rule-call-param WHERE
              buf_tt-rule-call-param.profile_id = p-profile-id
          AND buf_tt-rule-call-param.once-more = p-once-more
          AND buf_tt-rule-call-param.call_id = p-CALL-id
          AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
          AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
          AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
          AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
          AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
        v-found = yes.
      end.
    end.
    if not v-found then do:
      run rcps_proc-b-add in this-procedure (
                                               input p-rp-param-name
                                              ,input pp-index).
    end.
    FOR EACH  buf_rp-rule-param NO-LOCK where
        buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
        ,EACH buf_tt-rule-call-param WHERE
            buf_tt-rule-call-param.profile_id = p-profile-id
        AND buf_tt-rule-call-param.once-more = p-once-more
        AND buf_tt-rule-call-param.call_id = p-CALL-id
        AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
        AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
        AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
        AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
        AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
      assign
      buf_tt-rule-call-param.param-value-character = p-value-character
      buf_tt-rule-call-param.param-value-date      = p-value-date
      buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
      buf_tt-rule-call-param.param-value-integer   = p-value-integer
      buf_tt-rule-call-param.param-value-logical   = p-value-logical
      .
    END.
  END.
  WHEN 'rule-call-param':U THEN DO:
    FIND FIRST buf_tt-rule-call-param WHERE
        buf_tt-rule-call-param.call_id = p-call-id
    AND buf_tt-rule-call-param.codex_id = v-codex-id
    AND buf_tt-rule-call-param.ruleset_id = v-ruleset-id
    AND buf_tt-rule-call-param.order_id = v-order-id
    AND buf_tt-rule-call-param.param-name = V-PARAM-NAME
    AND buf_tt-rule-call-param.p-index = pp-index.
    assign
    buf_tt-rule-call-param.param-value-character = p-value-character
    buf_tt-rule-call-param.param-value-date      = p-value-date
    buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
    buf_tt-rule-call-param.param-value-integer   = p-value-integer
    buf_tt-rule-call-param.param-value-logical   = p-value-logical
    .
  END.
END CASE.
END PROCEDURE.
procedure rcps_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_get-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,output p-on-off) no-error.
end.
end procedure.
procedure rcps_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_set-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,input p-on-off) no-error.
end.
end procedure.
define variable v-ii as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-keys as character no-undo .
define new shared variable is-doc as logical no-undo .
define buffer find_rp-by-call for ub.rp-by-call.
IF p-list-mode = 'rp-rule-param':U
or p-list-mode = 'rp-rule-param':U  + chr(44) + 'все':U
THEN DO:
  FIND FIRST buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile_id = p-profile-id.
  run gen-key-rec in this-procedure ( input 'rule-profile':U
                                  ,input buffer buf_rule-profile:handle
                                  ,output v-uniq-key-rec).
  FIND FIRST buf_ruledict NO-LOCK WHERE
            buf_ruledict.entry-type = 'rule-profile':U
      AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
  v-rcps-entry-id = buf_ruledict.entry-id.
END.
RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-price-type as integer no-undo .
define variable v-r-b as character no-undo .
define variable custom-par as character no-undo .
custom-par = substitute("params-only=yes,params-only-mode=&1,parent-handle=&2,call=rp-by-call"
                      , p-mode
                      , this-procedure:handle)   .
custom-par = "'маг':U,4"  + chr(44) +
              substitute("X-SET_val_TYPE=&1", 1) + chr(44) +
             custom-par.
is-doc = yes.
run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-km6.w'
    , input "КМ-6":U
    , input 0
    , input ""
    , input "2"
    , input ""
    , input "1"
    , input custom-par
    , input NO
    ).
run rcps_proc-save0 in this-procedure .
