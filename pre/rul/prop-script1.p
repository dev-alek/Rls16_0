block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-language as character no-undo .
define input parameter        p-script-name   as character no-undo .
define input parameter        p-revis-id as integer no-undo .
define input parameter        p-script-label as character no-undo .
define input parameter        p-class-dtm-code as integer no-undo .
define input parameter        p-documentation as character no-undo .
define input parameter        p-proc-type as character no-undo .
define input parameter        p-script-type as character no-undo .
define input parameter        p-script-value-type as character no-undo .
define input parameter        p-script-head as character no-undo .
define input parameter        p-script-body as character no-undo .
define input parameter        p-script-foot as character no-undo .
define input parameter        p-signature as character no-undo .
define input parameter        p-hidden_  as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-script".
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
procedure signalib_fill-signature :
define input parameter p-script-name as character no-undo .
define input parameter p-script-head as character no-undo .
define input parameter p-proc-type as character no-undo .
DEFINE OUTPUT PARAMETER p-signature AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
define variable v-signature as character no-undo .
define variable v-params as character no-undo .
define variable v-entry as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  CASE p-proc-type:
    when 'class':U then do:
      p-signature = substitute("CLASS,,,,").
    end.
    when 'constructor':U then do:
      p-signature = substitute("CONSTRUCTOR,PUBLIC,,,void,").
    end.
    when 'destructor':U then do:
      p-signature = substitute("DESTRUCTOR,PUBLIC,,,void").
    end.
    when 'data-member':U then do:
      p-signature = substitute("DATA-MEMBER,PUBLIC," ).
    end.
    when 'property':U then do:
      p-signature = substitute("PROPERTY,PUBLIC,,").
    end.
    when 'method':U then do:
      assign
      p-signature = entry(1, p-script-head, "(")
      p-signature = replace(p-signature, chr(32) + chr(32) , chr(32) )
      p-signature = 'method':U + chr(44) + entry(2, p-signature, chr(32)) +
                                             chr(44) + entry(3, p-signature, chr(32)) +
                                             chr(44) + (if num-entries(p-signature, chr(32)) > 4
                                                              then  entry(5, p-signature, chr(32))
                                                              else '':U) +
                                             chr(44) + (if num-entries(p-signature, chr(32)) > 5
                                                              then  entry(6, p-signature, chr(32))
                                                              else '':U)
      .
      assign
      v-params = trim(entry(2, p-script-head , "(":U), ")") no-error
      .
      ASSIGN
      v-params = REPLACE(v-params, ")", "":U)
      v-params = REPLACE(v-params, ":", "":U)
      .
      if v-params <> '':U then do:
        do v-ii = 1 to num-entries(v-params):
            assign
            v-entry = trim(entry(v-ii, v-params), chr(32) )
            v-entry =  replace(v-entry, " as ", chr(32))
            v-entry =  replace(v-entry, "ub.", chr(32))
            v-entry =  replace(v-entry, " for ", "")
            v-entry = replace (v-entry, chr(32) + chr(32) , chr(32) )
            p-signature = p-signature + chr(44) + v-entry.
        end.
      end.
      else do:
        p-signature = p-signature + chr(44).
      end.
    end.
    when 'function':U then do:
      assign
      p-signature = entry(1, p-script-head, "(")
      p-signature = replace(p-signature, chr(32) + chr(32) , chr(32) )
      p-signature = replace(p-signature, "returns", "":U )
      p-signature = replace(p-signature, chr(32) + chr(32) , chr(32) )
      p-signature = 'function':U + chr(44) + entry(3, p-signature, chr(32))
      p-signature = trim(p-signature, ':')
      .
      assign
      v-params = trim(entry(2, p-script-head , "(":U), ")") no-error
      .
      ASSIGN
      v-params = REPLACE(v-params, ")", "":U)
      v-params = REPLACE(v-params, ":", "":U)
      .
      if v-params <> '':U then do:
        do v-ii = 1 to num-entries(v-params):
            assign
            v-entry = trim(entry(v-ii, v-params), chr(32) )
            v-entry =  replace(v-entry, " as ", chr(32))
            v-entry =  replace(v-entry, "ub.", chr(32))
            v-entry =  replace(v-entry, " for ", "")
            v-entry = replace (v-entry, chr(32) + chr(32) , chr(32) )
            p-signature = p-signature + chr(44) + v-entry.
        end.
      end.
      else do:
        p-signature = p-signature + chr(44).
      end.
    end.
  END CASE.
end.
end procedure.
FUNCTION signalib_get-params-from-signa returns character ( input p-proc-type as character
                                                           ,input p-signature-string as character):
define variable v-param-string as character no-undo .
v-param-string = p-signature-string.
case p-proc-type:
  when 'function':U
  or
  when 'procedure':U then do:
    entry(1, v-param-string) = '':U.
    if num-entries(v-param-string) > 1 then
    entry(2, v-param-string) = '':U.
    v-param-string = left-trim( v-param-string, chr(44)).
  end.
  when 'method':U
  or when 'constructor':U
  then do:
    entry(1, v-param-string) = '':U.
    entry(2, v-param-string) = '':U.
    entry(3, v-param-string) = '':U.
    entry(4, v-param-string) = '':U.
    entry(5, v-param-string) = '':U.
    v-param-string = left-trim( v-param-string, chr(44)).
  end.
  otherwise do:
    v-param-string = '':U.
  end.
end case.
return v-param-string.
end function.
procedure signalib_write-rdp :
define input parameter p-entry-id as integer no-undo .
define input parameter p-language as character no-undo .
define input parameter p-signature-param as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  for each buf_ruledict-param where
          buf_ruledict-param.entry-id = p-entry-id
      and buf_ruledict-param.language = p-language
  on error undo, return error:
      delete buf_ruledict-param.
  end.
  do v-ii = 1 to num-entries(p-signature-param):
    create buf_ruledict-param.
    assign
    buf_ruledict-param.entry-id = p-entry-id
    buf_ruledict-param.language = 'ABL':U
    buf_ruledict-param.param-num = v-ii
    buf_ruledict-param.param-mode = entry(1, entry(v-ii, p-signature-param), chr(32) )
    buf_ruledict-param.param-name = entry(2, entry(v-ii, p-signature-param), chr(32) )
    buf_ruledict-param.param-data-type = entry(3, entry(v-ii, p-signature-param), chr(32) )
    .
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
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-param-string as character no-undo .
define variable v-signature as character no-undo .
define variable v-signature0 as character no-undo .
define variable v-region-nl as character no-undo .
define variable v-script-label as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-revis-id as integer no-undo .
define variable glog as logical no-undo .
define buffer buf_prop-head  for ub.prop-head.
define buffer buf2_prop-head  for ub.prop-head.
define buffer buf_prop-script for ub.prop-script.
define buffer last_ruledict for ub.ruledict.
define buffer first_ruledict for ub.ruledict.
define buffer buf_ruledict for ub.ruledict.
define buffer last_prop-script for ub.prop-script.
define buffer buf_rule-i-script for ub.rule-i-script.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_prop-script
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  v-revis-id = p-revis-id.
  if p-language = '':U
  or p-script-name = '':U then do:
    assign
    v-mess = "Не задан язык и/или имя скрипта".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if lookup(p-proc-type, 'procedure,function,extern,dll-entry,main,class,data-member,property,method,constructor,destructor':u) = 0
  and p-proc-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа процедуры: &1", p-proc-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'proc-type':U).
  end.
  if lookup(p-script-type, 'set,get,get-ifunction,get-set,find,define_b,define_tt,define_h,create,function,ifunction,variable':u) = 0
  and p-script-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа скрипта: &1", p-script-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'script-type':U).
  end.
  if lookup(entry(1, p-script-value-type), 'character,date,decimal,integer,logical':U + chr(44) +
                                           'void':U + chr(44) +
                                           'handle':U
                                           ) = 0
  and p-proc-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа возвращаемых данных для скрипта: &1", p-script-value-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'script-value-type':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_prop-script no-lock where
              buf_prop-script.dtm-code = p-dtm-code
          and buf_prop-script.language = p-language
          and buf_prop-script.script-name = p-script-name
          and buf_prop-script.revis_id = p-revis-id no-error.
    if available buf_prop-script then do:
      assign
      v-mess = "Уже существует prop-script с таким именем для такого объекта, языка, Версии".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-dtm-code <> 0 then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = p-dtm-code no-error.
      if not available buf_prop-head then do:
        assign
        v-mess = substitute("Не существует Объект-операнд &1", p-dtm-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    create buf_prop-script.
    assign
    buf_prop-script.dtm-code = p-dtm-code
    buf_prop-script.language = p-language
    buf_prop-script.script-name = p-script-name
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_prop-script exclusive-lock where
              recid(buf_prop-script) = p-rec .
    if buf_prop-script.dtm-code <> p-dtm-code
    or buf_prop-script.language <> p-language
    or buf_prop-script.script-name <> p-script-name
    or buf_prop-script.revis_id <> p-revis-id
    then do:
      assign
      v-mess = substitute("Для уже существующего prop-script невозможно изменение Объекта, Языка, имени, версии&1" +
                              "старые значения объекта, языка, имени и версии: &2, &3, &4 &5"
                              , chr(10)
                              , buf_prop-script.dtm-code
                              , buf_prop-script.language
                              , buf_prop-script.script-name
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-class-dtm-code <> p-dtm-code then do:
      find first buf2_prop-head no-lock where
                buf2_prop-head.dtm-code = p-class-dtm-code no-error.
      if not available buf2_prop-head then do:
        assign
        v-mess = substitute("Не существует Объект-операнд обслуживающего класса &1", p-class-dtm-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    find first buf_rule-i-script no-lock where
              buf_rule-i-script.dtm-code = p-dtm-code
         and  buf_rule-i-script.class-dtm-code = p-class-dtm-code
         and  buf_rule-i-script.script-name = p-script-name
         and  buf_rule-i-script.script-type = p-script-type
         and  buf_rule-i-script.revis_id = p-revis-id no-error.
    if available buf_rule-i-script then do:
      if not p-silent then do:
         message
         "Скрипт данной версии входит в правила" skip
         "Хотите создать скрипт новой версии?"
         view-as alert-box question buttons YES-NO update glog.
      end.
      else do:
        glog = yes.
      end.
      if not glog then do:
        return.
      end.
      find last last_prop-script no-lock where
              last_prop-script.dtm-code = p-dtm-code
          and last_prop-script.language = p-language
          and last_prop-script.script-name = p-script-name no-error.
      if available last_prop-script then do:
        v-revis-id =  last_prop-script.revis_id + 1.
      end.
      else do:
        v-revis-id =  0.
      end.
    end.
  end.
  if p-proc-type <> '':U then do:
    if (p-signature begins "@") then do:
      assign
      v-signature = left-trim(p-signature, "@")
      v-signature0 = p-signature
      .
    end.
    else do:
      run signalib_fill-signature in this-procedure ( input p-script-name
                                          ,input p-script-head
                                          ,input p-proc-type
                                          ,output v-signature) no-error.
      if error-status:error then do:
        assign
        v-mess = substitute("Ошибки при заполнении сигнатуры&1&2&1&3"
                           , chr(10)
                           , error-status:get-message(1)
                           , return-value
                           ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
      v-signature0 = v-signature.
    end.
  end.
  if p-script-label = '':U then do:
    if p-dtm-code > 0
    then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = p-dtm-code .
      if index(p-script-name, "_host@") > 0
      or index(p-script-name, "_host@#") > 0
      or r-index(p-script-name, "_host") = length(entry(1, p-script-name, "(")) - 4 then do:
        v-region-nl = "_Фирма".
      end.
      if index(p-script-name, "_obj@") > 0
      or index(p-script-name, "_obj@#") > 0
      or r-index(p-script-name, "_obj") = length(entry(1, p-script-name, "(")) - 3 then do:
        v-region-nl = "_Объект".
      end.
      if index(p-script-name, "_@") > 0
      or index(p-script-name, "_@#") > 0
      or r-index(p-script-name, "_") = length(entry(1, p-script-name, "(")) then do:
        v-region-nl = "_".
      end.
      if index(p-script-name, "@":U) > 0 then do:
        v-script-label = buf_prop-head.prop-label + v-region-nl + '.':U + p-script-label.
      end.
      else do:
        v-script-label = buf_prop-head.prop-label + v-region-nl.
      end.
    end.
    else do:
      v-script-label = p-script-label.
    end.
    if p-script-type = 'set':U
    then do:
      assign
      v-script-label = substitute ('&1 = &&1', v-script-label).
    end.
    if p-script-type = 'create':U then do:
      assign
      v-script-label = substitute ('&1.Создать', v-script-label).
    end.
  end.
  else do:
    v-script-label = p-script-label.
  end.
  assign
  buf_prop-script.class-dtm-code = p-class-dtm-code
  buf_prop-script.documentation = p-documentation
  buf_prop-script.proc-type     = p-proc-type
  buf_prop-script.script-type   = p-script-type
  buf_prop-script.script-value-type    = p-script-value-type
  buf_prop-script.script-head   = p-script-head
  buf_prop-script.script-body   = p-script-body
  buf_prop-script.script-foot   = p-script-foot
  buf_prop-script.signature     = v-signature0
  buf_prop-script.revis_id      = v-revis-id
  buf_prop-script.hidden_       = p-hidden_
  p-rec = recid(buf_prop-script)
  .
  run gen-key-rec in this-procedure (
                                      input 'prop-script':U
                                      ,input  buffer buf_prop-script:handle
                                      ,output v-uniq-key-rec
                                      ).
  assign
  buf_prop-script.uniq-key-rec = v-uniq-key-rec
  .
  find first buf_ruledict where
            buf_ruledict.entry-type  = 'prop-script':U
        and buf_ruledict.uniq-key-rec  = v-uniq-key-rec no-error.
  if not available buf_ruledict then do:
    find first first_ruledict exclusive-lock use-index pi.
    find last last_ruledict no-lock use-index pi.
    create buf_ruledict.
    assign
    buf_ruledict.entry-type = 'prop-script':U
    buf_ruledict.uniq-key-rec = v-uniq-key-rec
    buf_ruledict.entry-id = last_ruledict.entry-id + 1
    buf_ruledict.language = "ABL"
    .
  end.
  assign
  buf_ruledict.script-al = p-script-name
  buf_ruledict.script-nl = v-script-label
  .
  assign
  v-param-string = signalib_get-params-from-signa( input p-proc-type, input v-signature).
  if v-param-string <> '':U then do:
    run signalib_write-rdp  in this-procedure ( input buf_ruledict.entry-id
                                    ,input "ABL":U
                                    ,input v-param-string
                                    ) .
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Скрипт: объект-операнд &1 язык: &2: скрипт &3 версия &4:&5&6"
                         , p-dtm-code
                         , p-language
                         , p-script-name
                         , p-revis-id
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
