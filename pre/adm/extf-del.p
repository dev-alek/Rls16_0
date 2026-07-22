block-level on error undo, throw.
define parameter buffer buf_ext-file for ub.ext-file.
define input parameter p-tree as logical no-undo .
define input parameter p-status_ as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extf-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/extf-del.p $":U .
define variable vss-description as character no-undo init "Удаление пакета обновлений".
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
define  temp-table tt-ext-file-par no-undo like ub.ext-file-par.
procedure ext-file-par-clear-temp :
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    for each buf_tt-ext-file-par
    on error undo, return error
    :
      delete buf_tt-ext-file-par .
    end.
  end.
end procedure.
procedure ext-file-par-write-temp :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_tt-ext-file-par
      where buf_tt-ext-file-par.db-num        = p-db-num
        and buf_tt-ext-file-par.file-num      = p-file-num
        and buf_tt-ext-file-par.from-db-num   = p-from-db-num
        and buf_tt-ext-file-par.param-type    = p-value-type
        and buf_tt-ext-file-par.param-name    = p-value-name
      no-error .
    if not available buf_tt-ext-file-par then do:
      create buf_tt-ext-file-par .
      assign
        buf_tt-ext-file-par.db-num         = p-db-num
        buf_tt-ext-file-par.from-db-num    = p-from-db-num
        buf_tt-ext-file-par.file-num       = p-file-num
        buf_tt-ext-file-par.param-num      = p-param-num
        buf_tt-ext-file-par.param-type     = p-value-type
        buf_tt-ext-file-par.user-db-num    = p-db-num
              .
    end.
    CASE p-value-type:
      when 'C':U
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_tt-ext-file-par.param-name = p-value-name
        buf_tt-ext-file-par.param-value = p-value-char
        .
      end.
      when 'T':U then do:
        assign
        buf_tt-ext-file-par.param-date-name = p-value-name
        buf_tt-ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_tt-ext-file-par.param-int-name = p-value-name
        buf_tt-ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'L':U then do:
        assign
        buf_tt-ext-file-par.param-log-name = p-value-name
        buf_tt-ext-file-par.param-log-value = p-value-logical
        .
      end.
      when 'D':U then do:
        assign
        buf_tt-ext-file-par.param-decimal-name = p-value-name
        buf_tt-ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
    END CASE.
  end.
end procedure.
procedure ext-file-par-write-and-send :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define input  parameter p-send        as logical no-undo .
  define input  parameter p-list-db-num as character no-undo .
  define buffer buf_ext-file-par for ub.ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_ext-file-par
      where buf_ext-file-par.db-num         = p-db-num
        and buf_ext-file-par.from-db-num    = p-from-db-num
        and buf_ext-file-par.file-num       = p-file-num
        and buf_ext-file-par.param-num      = p-param-num
      no-error .
    if not available buf_ext-file-par then do:
      create buf_ext-file-par .
      assign
        buf_ext-file-par.db-num    = p-db-num
        buf_ext-file-par.from-db-num    = p-from-db-num
        buf_ext-file-par.file-num    = p-file-num
        buf_ext-file-par.param-num    = p-param-num
        buf_ext-file-par.param-type   = p-value-type
        buf_ext-file-par.user-db-num    = p-db-num
      .
    end.
    CASE p-value-type:
      when 'C':U
      or when ''
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_ext-file-par.param-name = p-value-name
        buf_ext-file-par.param-value = p-value-char
        .
        if p-value-type = ''
        and p-param-num = 0 then do:
          buf_ext-file-par.param-log-value = p-value-logical.
        end.
      end.
      when 'T':U then do:
        assign
        buf_ext-file-par.param-date-name = p-value-name
        buf_ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_ext-file-par.param-int-name = p-value-name
        buf_ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'D':U then do:
        assign
        buf_ext-file-par.param-decimal-name = p-value-name
        buf_ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
      when 'L':U then do:
        assign
        buf_ext-file-par.param-log-name = p-value-name
        buf_ext-file-par.param-log-value = p-value-logical
        .
      end.
    END CASE.
    if p-send then do:
      run nws/cr-route.p (
                      input 'send-tbl':U
                    , input 'ext-file-par':U
                    , input buffer buf_ext-file-par:handle
                    , input p-list-db-num) no-error.
    end.
  end.
end procedure.
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
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer locked_ext-file for ub.ext-file.
define buffer buf_Ext-file-line for ub.ext-file-line.
define buffer buf2_ext-file for ub.ext-file.
define buffer buf_ext-file-par for ub.ext-file-par.
define buffer tree_ext-file for ub.ext-file.
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if buf_ext-file.from-db-num <> g#db-num
  and not g#news
  and not p-tree
  then do:
    undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5 - он создан в другой БД"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , chr(10)
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
  end.
  if buf_ext-file.file-type begins 'cash-desk':U + chr(3)
  and buf_ext-file.file-type <> 'cash-desk':U + chr(3)
  and not p-tree
  then do:
    undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5 - логи и ответы с касс удаляются ТОЛЬКО вместе с файлом-запросом"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , chr(10)
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
  end.
  if p-status_ = '':U
  and buf_ext-file.file-type begins "u" then do:
    find first buf2_ext-file no-lock where
              buf2_ext-file.db-num = buf_ext-file.db-num
         and  buf2_ext-file.from-db-num = buf_ext-file.from-db-num
         and  buf2_ext-file.file-name = buf_ext-file.file-type no-error.
     if available buf2_ext-file then do:
      undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5" +
                                    "Для удаления файлов пакетов обновлений существует специальный режим"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , chr(10)
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
    end.
  end.
  find first locked_ext-file exclusive-lock where recid(locked_Ext-file) = recid(buf_ext-file).
  if locked_Ext-file.file-type = locked_ext-file.file-name then do:
    if p-status_ = '':U
    and buf_ext-file.file-type begins "u" then do:
    for each buf2_ext-file where
          buf2_ext-file.db-num = locked_ext-file.db-num
      and buf2_ext-file.from-db-num = locked_ext-file.from-db-num
      and buf2_ext-file.file-type = locked_ext-file.file-type
    on error undo, return error return-value
    on stop undo, return error return-value :
      for each buf_Ext-file-line where
              buf_Ext-file-line.db-num = locked_Ext-file.db-num
          and buf_Ext-file-line.from-db-num = locked_Ext-file.from-db-num
          and buf_Ext-file-line.file-num = buf2_Ext-file.file-num
      on error undo, return error return-value
      on stop undo, return error return-value :
          delete buf_Ext-file-line.
      end.
      for each buf_ext-file-par where
              buf_ext-file-par.db-num = locked_ext-file.db-num
          and buf_ext-file-par.from-db-num = locked_ext-file.from-db-num
          and buf_ext-file-par.file-num = locked_ext-file.file-num
      on error undo, return error return-value
      on stop undo, return error return-value :
          delete buf_ext-file-par.
      end.
      end.
    end.
  end.
  if buf_ext-file.file-type = 'cash-desk':U + chr(3) then do:
    for each buf_ext-file-par no-lock where
            buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
        if buf_ext-file-par.param-type = 'uniq-key-rec':U
        and buf_ext-file-par.param-value begins 'ext-file':U then do:
          run gen-row-keyr in this-procedure (
                                            input  buf_ext-file-par.param-value
                                            ,input  ?
                                            ,input  "ub"
                                            ,input  ?
                                            ,input  EXCLUSIVE-LOCK
                                            ,output v-tbl-row
                                            ,output v-tbl-name   ) no-error.
          if error-status:error then do:
            undo main-block, return error substitute("Ошибка при удалении файла БД &1 (от БД &2) &3№ файла &4&3&5 - не найден связанный файл &6"
                                                    , buf_ext-file.db-num
                                                    , buf_ext-file.from-db-num
                                                    , chr(10)
                                                    , buf_ext-file.file-num
                                                    , buf_ext-file.file-name
                                                    , buf_ext-file-par.param-value
                                                    ).
          end.
          if v-tbl-row <> ? then do:
          find first tree_ext-file exclusive-lock where
                    rowid(tree_ext-file) = v-tbl-row.
          run adm/extf-del.p (  buffer tree_ext-file
                              ,input yes
                              ,input p-status_ ) no-error.
          if error-status:error then do:
            undo main-block, return error substitute("Ошибка при удалении файла БД &1 (от БД &2) &3№ файла &4&3&5 - ошибка при удалении связанного файла &6"
                                                    , buf_ext-file.db-num
                                                    , buf_ext-file.from-db-num
                                                    , chr(10)
                                                    , buf_ext-file.file-num
                                                    , buf_ext-file.file-name
                                                    , buf_ext-file-par.param-value
                                                    ).
          end.
        end.
    end.
  end.
  end.
  for each buf_Ext-file-line where
          buf_Ext-file-line.db-num = locked_Ext-file.db-num
      and buf_Ext-file-line.from-db-num = locked_Ext-file.from-db-num
      and buf_Ext-file-line.file-num = locked_Ext-file.file-num
  on error undo, return error return-value
  on stop undo, return error return-value :
    delete buf_Ext-file-line.
  end.
  for each buf_Ext-file-par where
          buf_Ext-file-par.db-num = locked_Ext-file.db-num
      and buf_Ext-file-par.from-db-num = locked_Ext-file.from-db-num
      and buf_Ext-file-par.file-num = locked_Ext-file.file-num
  on error undo, return error return-value
  on stop undo, return error return-value :
    delete buf_Ext-file-par.
  end.
  if not (
          g#db-num = locked_ext-file.db-num
          and
          locked_ext-file.db-num = locked_ext-file.from-db-num
        )
  and not g#news
  and not p-tree
    then do:
      run nws/cmd-del.p
        ( input 'ext-file':U
        ,input (buffer locked_ext-file:handle)
        ,input string(if g#db-num > 0 then 0 else abs(locked_ext-file.db-num))
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  delete buf_Ext-file.
end.
