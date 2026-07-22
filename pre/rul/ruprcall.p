block-level on error undo, throw.
define input parameter p-call-type as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-data-completeness  as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define input parameter table for tt0-rp-by-call.
define input parameter table for tt0-rule-by-call.
define input parameter table for tt0-rule-call-param.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки профайла, правил, параметров вызова правил".
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
define temp-table temp-rule-reusable no-undo
field call_id as character
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field profile_id as integer
field rule_id as integer
field reusable-string as character
index pi is unique primary
call_id codex_id  ruleset_id order_id
index ireuse
call_id
codex_id
ruleset_id
rule_id
reusable-string
.
procedure check-reusable :
define input parameter p-call-id as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-reusable-string as character no-undo .
define output parameter p-can-run as logical no-undo init yes.
define buffer buf_temp-rule-reusable for temp-rule-reusable.
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-ii as integer no-undo .
define variable v-reusable-string as character no-undo .
do
on error undo, return error return-value
:
   if p-reusable-string = "0" then return.
   if p-reusable-string = "-":u then do:
     v-reusable-string = string(p-rule-id).
   end.
   else do:
     do v-ii = 1 to num-entries(p-reusable-string):
        find first buf_rule-call-param no-lock where
                 buf_rule-call-param.codex_id = p-codex-id
             and buf_rule-call-param.ruleset_id = p-ruleset-id
             and buf_rule-call-param.call_id = p-call-id
             and buf_rule-call-param.order_id = p-order-id
             and buf_rule-call-param.rule_id = p-rule-id
             and buf_rule-call-param.param-name = entry(v-ii, p-reusable-string)
             and buf_rule-call-param.p-index = 0
             no-error.
        if available buf_rule-call-param then do:
          assign
          v-reusable-string = v-reusable-string + (if v-reusable-string = '':u then '':U else chr(3)) +
                              buffer buf_rule-call-param:buffer-field(substitute("param-value-&1"
                                                                     , entry(1, buf_rule-call-param.param-data-type, "_"))):string-value
          .
        end.
     end.
   end.
   find first buf_temp-rule-reusable no-lock where
            buf_temp-rule-reusable.reusable-string = v-reusable-string
        and buf_temp-rule-reusable.rule_id = p-rule-id
        and buf_temp-rule-reusable.call_id = p-call-id
        and buf_temp-rule-reusable.codex_id = p-codex-id
        and buf_temp-rule-reusable.ruleset_id = p-ruleset-id  no-error.
   if available buf_temp-rule-reusable then do:
     p-can-run = no.
   end.
   create buf_temp-rule-reusable.
   assign
   buf_temp-rule-reusable.call_id = p-call-id
   buf_temp-rule-reusable.codex_id = p-codex-id
   buf_temp-rule-reusable.ruleset_id = p-ruleset-id
   buf_temp-rule-reusable.order_id = p-order-id
   buf_temp-rule-reusable.profile_id = p-profile-id
   buf_temp-rule-reusable.rule_id = p-rule-id
   buf_temp-rule-reusable.reusable-string = v-reusable-string
   .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure who-lk_make-some-lk :
define input  parameter p-resource-id as character no-undo .
define input  parameter p-call-id as character no-undo .
define input  parameter p-call#-id as integer   no-undo .
define input  parameter p-lk-type as character no-undo .
define input  parameter p-corr-user-db-num as integer   no-undo .
define input  parameter p-lk-mess as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-resource#-id as integer   no-undo .
define buffer buf_who-lk for ub.who-lk.
define buffer buf_some-lk for ub.some-lk.
do
on error undo, return error return-value
:
   find first buf_who-lk no-lock where
            buf_who-lk.resource_id = p-resource-id
       and buf_who-lk.call_id = p-call-id
       and buf_who-lk.lk-type = p-lk-type
       and buf_who-lk.corr-user-db-num = p-corr-user-db-num
       no-error.
   if available buf_who-lk then return ''.
   find first buf_some-lk no-lock where
            buf_some-lk.resource_id = p-resource-id
        and buf_some-lk.lk-type = p-lk-type
            no-error.
   if not available buf_some-lk then do:
     run rul/g-callid.p ( input 'some-lk':U
                         ,input p-resource-id
                         ,output v-resource#-id).
     create buf_some-lk.
     assign
     buf_some-lk.resource_id = p-resource-id
     buf_some-lk.resource#_id = v-resource#-id
     buf_some-lk.lk-type = p-lk-type
     .
   end.
   else do:
     find current buf_some-lk exclusive-lock.
   end.
   assign
   buf_some-lk.counter = buf_some-lk.counter + 1
   .
   run cur-time in this-procedure(output v-today, output v-time).
   create buf_who-lk.
   assign
   buf_who-lk.call_id = p-call-id
   buf_who-lk.call#_id = p-call#-id
   buf_who-lk.chip-num = next-value(s-lk-chip, ub)
   buf_who-lk.lk-mess      = p-lk-mess
   buf_who-lk.lk-type      = p-lk-type
   buf_who-lk.PS           = p-ps
   buf_who-lk.resource#_id = buf_some-lk.resource#_id
   buf_who-lk.resource_id = buf_some-lk.resource_id
   buf_who-lk.corr-user-db-num = p-corr-user-db-num
   buf_who-lk.corr-user-name = g#userid
   buf_who-lk.corr-date = v-today
   buf_who-lk.corr-time = v-time
   .
end.
end procedure.
procedure who-lk_delete-some-lk :
define input  parameter p-resource-id as character no-undo .
define input  parameter p-call-id as character no-undo .
define input  parameter p-lk-type as character no-undo .
define input  parameter p-corr-user-db-num as integer   no-undo .
define buffer buf_who-lk for ub.who-lk.
define buffer buf_some-lk for ub.some-lk.
do
on error undo, return error return-value
:
   find first buf_some-lk no-lock where
            buf_some-lk.resource_id = p-resource-id
        and buf_some-lk.lk-type = p-lk-type
            no-error.
   if not available buf_some-lk then return ''.
   find first buf_who-lk no-lock where
            buf_who-lk.resource_id = p-resource-id
       and buf_who-lk.call_id = p-call-id
       and buf_who-lk.lk-type = p-lk-type
       and buf_who-lk.corr-user-db-num = p-corr-user-db-num
       no-error.
   if not available buf_who-lk then return ''.
   find current buf_who-lk exclusive-lock.
   find current buf_some-lk exclusive-lock .
   assign
   buf_some-lk.counter = buf_some-lk.counter - 1.
   delete buf_who-lk.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info9 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
define variable v-call#-id as integer no-undo .
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
define variable v-run-bush-command as logical no-undo .
define variable v-cmp as logical no-undo .
define variable v-cmp-loc as logical no-undo .
define variable v-old-can-run as logical no-undo .
define variable v-old-can-calc as logical no-undo .
define variable v-create-command as logical no-undo .
define variable v-command as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rec-ord as integer no-undo .
define variable v-rcp-key-rec as character no-undo .
define variable v-db-list as character no-undo .
define buffer buf_db for ub.db .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define temp-table temp-prop-ref-call  no-undo like ub.prop-ref-call.
define temp-table temp-uniq-key no-undo
field key-rec as character
index pi is unique primary key-rec
.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-run-bush-command = valid-handle(p-cmd-proc-handle).
  if v-call#-id = 0 then do:
    run rul/g-callid.p ( input p-call-type
                        ,input p-call-id
                        ,output v-call#-id).
  end.
  if not v-run-bush-command then do:
    if p-cmd-code = 0 then do:
      v-create-command = yes.
      run  gen-key-fv in this-procedure (
                                          input p-call-id
                                         ,output v-field-list
                                         ,output v-value-list).
      case p-call-type:
        when 'dis-card-type':U then do:
          assign
          v-command =  substitute("&2&1&3&1&4"
                                , chr(6)
                                , 'cmd-dct-send':U
                                , integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)))
                                , entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                                ).
        end.
        when 'goods':U
        or
        when 'clients':U
        or
        when 'gds-grp':U
        or
        when 'cli-grp':U
        or
        when 'thref':U
        or
        when 'edoc':U
        or
        when 'rep':U
        or
        when 'chk-doc':U + "_" + 'IBS-TH':U
        or
        when 'chk-doc':U + "_" + 'IBS-TH-MOB':U
        or
        when 'ord':U
        then do:
          if p-call-type = 'rep':U
          or p-call-type = 'ord':U
          then do:
            if entry(1, p-call-id, chr(3)) = 'schedule':U then do:
              define variable v-cre-db-num as integer no-undo .
              v-cre-db-num =  integer(entry(lookup("cre-db-num", v-field-list, chr(3)), v-value-list, chr(3))).
              if v-cre-db-num > 0
              then do:
                if g#db-num > 0 then do:
                  v-db-list = string(0).
                end.
                else do:
                  v-db-list = string(v-cre-db-num).
                end.
              end.
              else do:
                v-create-command = no.
              end.
            end.
          end.
          if v-create-command then do:
          assign
            v-command =  substitute("&2&1&3&1"
                                , chr(6)
                                  , 'cmd-rum-send':U
                                ,  str-encode( p-call-id
                                       , ""
                                       , chr(3))
                                ).
        end.
        end.
      end case.
      if v-create-command then do:
      run nws/cmd-bush.p persistent set p-cmd-proc-handle no-error .
      if error-status :error
      then do:
        delete procedure p-cmd-proc-handle .
        message
        substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                            "&5&4&6"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,error-status:get-message(1)
                                            ,return-value ).
        undo _main, return error.
      end.
      if g#db-num = 0 then do:
        for each buf_db no-lock
        where buf_db.db-num > 0
        :
          assign
          v-db-list = v-db-list + chr(1) + string(buf_db.db-num).
        end.
        v-db-list = trim(v-db-list, chr(1)).
      end.
      else do:
        v-db-list = '0'.
      end.
      run begin-create-command in p-cmd-proc-handle
        (input v-command
          ,input v-db-list
        ,output p-cmd-code
        ) no-error.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", 'cmd-dct-send':U ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        delete procedure p-cmd-proc-handle .
        undo _main, return error return-value .
      end.
      v-run-bush-command = yes.
      end.
    end.
  end.
  if lookup('rp-by-call':U, p-data-completeness) > 0 then do:
    for each buf_rp-by-call where
              buf_rp-by-call.call_id = p-call-id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
      find first tt0-rp-by-call no-lock where
                tt0-rp-by-call.call_id = p-call-id
            and tt0-rp-by-call.profile_id = buf_rp-by-call.profile_id
            and tt0-rp-by-call.once-more = buf_rp-by-call.once-more  no-error.
      if not available tt0-rp-by-call then do:
        if v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rp-by-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rp-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rp-by-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
        run delete-from-rp-by-call in this-procedure ( input buf_rp-by-call.call_id
                                                      ,input buf_rp-by-call.profile_id
                                                      ,input buf_rp-by-call.once-more) .
        delete buf_rp-by-call.
      end.
    end.
    for each tt0-rp-by-call
    where tt0-rp-by-call.call_id = p-call-id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      v-cmp-loc = yes.
      find first buf_rp-by-call where
                buf_rp-by-call.call_id = tt0-rp-by-call.call_id
            and buf_rp-by-call.profile_id = tt0-rp-by-call.profile_id
            and buf_rp-by-call.once-more = tt0-rp-by-call.once-more  no-error .
      if not available buf_rp-by-call then do:
        find first buf_rule-profile no-lock where
                  buf_rule-profile.profile_id = tt0-rp-by-call.profile_id no-error.
        if not available buf_rule-profile then do:
          UNDO _main, return error substitute( "&1. Не найден профайл правил с id &2", vss-workfile, tt0-rp-by-call.profile_id).
        end.
        if buf_rule-profile.param-code <> '':U then do:
          if buf_rule-profile.param-code = 'sys-key' then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-par-val
  ) no-error .
            if error-status:error then do:
              undo _main, return error
              substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                          "который должен быть включен для работы профайла &3"
                          ,buf_rule-profile.param-code
                          ,chr(10)
                          ,buf_rule-profile.profile_id).
            end.
          end.
          else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_rule-profile.param-code
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-par-val
  ,output v-par-type
  ) no-error .
            if error-status:error then do:
              undo _main, return error
              substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                          "который должен быть включен для работы профайла &3"
                          ,buf_rule-profile.param-code
                          ,chr(10)
                          ,buf_rule-profile.profile_id).
            end.
          end.
          if (buf_rule-profile.param-code = 'sys-key'
          and check-entry-with-mask(v-par-val, buf_rule-profile.param-value, chr(4)) = no
          and not (buf_rule-profile.param-code = 'sys-key'
                      and
                      v-par-val = 'IBS')
                )
              or (buf_rule-profile.param-code <> 'sys-key'
              and lookup(v-par-val, buf_rule-profile.param-value, chr(4)) = 0)
          then do:
              undo _main, return error
              substitute("Значения конфигурационного параметра &1=&2,&3" +
                          "что не удовлетворяет условиям работы профайла &4"
                          ,buf_rule-profile.param-code
                          ,v-par-val
                          ,chr(10)
                          ,buf_rule-profile.profile_id).
          end.
        end.
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        create buf_rp-by-call.
        assign
        buf_rp-by-call.call_id = tt0-rp-by-call.call_id
        buf_rp-by-call.call#_id = v-call#-id
        buf_rp-by-call.profile_id = tt0-rp-by-call.profile_id
        buf_rp-by-call.once-more = tt0-rp-by-call.once-more
        buf_rp-by-call.ps = tt0-rp-by-call.ps
        buf_rp-by-call.parent-profile_id = tt0-rp-by-call.parent-profile_id
        buf_rp-by-call.parent-once-more = tt0-rp-by-call.parent-once-more
        .
        assign
        v-cmp-loc = no
        .
      end.
      else do:
        buffer-compare tt0-rp-by-call to
        buf_rp-by-call save result in v-cmp-loc.
        if not v-cmp-loc then
        do:
           assign buf_rp-by-call.ps = tt0-rp-by-call.ps
           .
        end.
      end.
      if not v-cmp-loc and v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rp-by-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rp-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rp-by-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
      end.
    end.
  end.
  define buffer on_tt0-rule-by-call for tt0-rule-by-call.
  define buffer on_buf_rule-by-call for ub.rule-by-call.
  if lookup('rule-call-param':U, p-data-completeness) > 0 then do:
    _tt0-rule-call-param:
    for each tt0-rule-call-param
    where tt0-rule-call-param.call_id = p-call-id
    break
    by tt0-rule-call-param.call_id
    by tt0-rule-call-param.codex_id
    by tt0-rule-call-param.ruleset_id
    by tt0-rule-call-param.order_id
    by tt0-rule-call-param.rule_id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      if first-of (tt0-rule-call-param.rule_id) then do:
        find first buf_rule exclusive-lock where
                  buf_rule.rule_id = tt0-rule-call-param.rule_id .
        find first buf_ruledict exclusive-lock where
                  buf_ruledict.entry-type = 'rule':U
              and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
        _ruledict-param:
        for each buf_ruledict-param no-lock where
                buf_ruledict-param.entry-id  = buf_ruledict.entry-id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          if lookup("temp", buf_ruledict-param.param-3-data-type) > 0  then do:
            next _ruledict-param.
          end.
          find first buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.rule_id = tt0-rule-call-param.rule_id
              and buf_tt0-rule-call-param.call_id = tt0-rule-call-param.call_id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num no-error .
          if not available buf_tt0-rule-call-param then do:
            undo _main, return error substitute("Не найдено значение параметра № &1 для вызова правила &2:&3" +
                                                "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                , buf_tt0-rule-call-param.param-num
                                                , tt0-rule-call-param.rule_id
                                                , chr(10)
                                                , p-call-id
                                                , tt0-rule-call-param.codex_id
                                                , tt0-rule-call-param.ruleset_id
                                                , tt0-rule-call-param.order_id).
          end.
          for each buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.rule_id = tt0-rule-call-param.rule_id
              and buf_tt0-rule-call-param.call_id = tt0-rule-call-param.call_id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num
          on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
          ON STOP undo _MAIN, return error '':u:
            if buf_tt0-rule-call-param.param-data-type <> buf_ruledict-param.param-data-type
            or buf_tt0-rule-call-param.param-mode <> buf_ruledict-param.param-mode then do:
              undo _main, return error substitute("Неверный тип или мода параметра № &1 для вызова правила &2:&3" +
                                                  "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                  , buf_tt0-rule-call-param.param-num
                                                  , tt0-rule-call-param.rule_id
                                                  , chr(10)
                                                  , p-call-id
                                                  , tt0-rule-call-param.codex_id
                                                  , tt0-rule-call-param.ruleset_id
                                                  , tt0-rule-call-param.order_id) +
                                      substitute("&1Для правила задано: тип данных &2, мода &3&1" +
                                                  "Для точки вызова: тип данных &4, мода &5"
                                                  , chr(10)
                                                  , buf_ruledict-param.param-data-type
                                                  , buf_ruledict-param.param-mode
                                                  , buf_tt0-rule-call-param.param-data-type
                                                  , buf_tt0-rule-call-param.param-mode).
            end.
            if buf_tt0-rule-call-param.p-index = 0
            and lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) > 0
            then do:
              run check-list-unique in this-procedure ( input buf_tt0-rule-call-param.call_id
                                                       ,input buf_tt0-rule-call-param.codex_id
                                                       ,input buf_tt0-rule-call-param.ruleset_id
                                                       ,input buf_tt0-rule-call-param.order_id
                                                       ,input buf_tt0-rule-call-param.param-name
                                                       ,input buf_tt0-rule-call-param.param-data-type
                                                        ) no-error.
              if error-status:error then do:
                undo _main, return error substitute("Неверное значение параметра № &1(&8) для вызова правила &2:&3" +
                                                    "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7&3" +
                                                    "профайл &8&3" +
                                                    "Имеются ДУБЛИ в параметре типа СПИСОК"
                                                    , buf_tt0-rule-call-param.param-num
                                                    , tt0-rule-call-param.rule_id
                                                    , chr(10)
                                                    , p-call-id
                                                    , tt0-rule-call-param.codex_id
                                                    , tt0-rule-call-param.ruleset_id
                                                    , tt0-rule-call-param.order_id
                                                    , tt0-rule-call-param.profile_id
                                                    , buf_tt0-rule-call-param.param-name
                                                    ).
              end.
            end.
            if buf_tt0-rule-call-param.param-2-data-type <> '':U then do:
              if  lookup('rule-by-call':U, p-data-completeness) > 0 then do:
                find first on_tt0-rule-by-call where
                          on_tt0-rule-by-call.call_id = buf_tt0-rule-call-param.call_id
                      and on_tt0-rule-by-call.codex_id = buf_tt0-rule-call-param.codex_id
                      and on_tt0-rule-by-call.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and on_tt0-rule-by-call.order_id = buf_tt0-rule-call-param.order_id no-error .
              end.
              else do:
                find first on_buf_rule-by-call where
                          on_buf_rule-by-call.call_id = buf_tt0-rule-call-param.call_id
                      and on_buf_rule-by-call.codex_id = buf_tt0-rule-call-param.codex_id
                      and on_buf_rule-by-call.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and on_buf_rule-by-call.order_id = buf_tt0-rule-call-param.order_id no-error .
              end.
              assign
              v-ok = no
              v-value-character = buf_tt0-rule-call-param.param-value-character
              v-value-date = buf_tt0-rule-call-param.param-value-date
              v-value-decimal = buf_tt0-rule-call-param.param-value-decimal
              v-value-integer = buf_tt0-rule-call-param.param-value-integer
              v-value-logical = buf_tt0-rule-call-param.param-value-logical
              .
              run ref/rule-dtt.p (
                                  input ?
                                  ,input 'ПРОВЕРКА':U
                                  ,input p-call-id
                                  ,input buf_tt0-rule-call-param.param-data-type
                                  ,input buf_tt0-rule-call-param.param-2-data-type
                                  ,input buf_tt0-rule-call-param.param-3-data-type
                                  ,input buf_tt0-rule-call-param.p-index
                                  ,input-output v-value-character
                                  ,input-output v-value-date
                                  ,input-output v-value-decimal
                                  ,input-output v-value-integer
                                  ,input-output v-value-logical
                                  ,output v-ok
                                  ) no-error.
              if error-status:error
              or not v-ok then do:
                undo _main, return error substitute("Неверное значение параметра № &1(&8) для вызова правила &2:&3" +
                                                    "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7&3&9"
                                                    , buf_tt0-rule-call-param.param-num
                                                    , tt0-rule-call-param.rule_id
                                                    , chr(10)
                                                    , p-call-id
                                                    , tt0-rule-call-param.codex_id
                                                    , tt0-rule-call-param.ruleset_id
                                                    , tt0-rule-call-param.order_id
                                                    , buf_tt0-rule-call-param.param-name
                                                    , return-value
                                                    ).
              end.
              if buf_tt0-rule-call-param.p-index > 0
              or lookup("LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
              or lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
              then do:
                run gen-key-rec in this-procedure (
                                                   input 'rule-call-param':U
                                                  ,input buffer buf_tt0-rule-call-param:handle
                                                  ,output v-rcp-key-rec).
                find first temp-uniq-key where temp-uniq-key.key-rec = v-rcp-key-rec no-error.
                if not available temp-uniq-key then do:
                  create temp-uniq-key.
                  temp-uniq-key.key-rec = v-rcp-key-rec.
                  run update-prop-ref-call in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                              ,input buf_tt0-rule-call-param.param-2-data-type
                                                              ,input buf_tt0-rule-call-param.param-3-data-type
                                                              ,input buf_tt0-rule-call-param.param-value-character
                                                              ,input buf_tt0-rule-call-param.call_id).
                end.
                run update-dis-rule in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                        ,input buf_tt0-rule-call-param.param-2-data-type
                                                        ,input buf_tt0-rule-call-param.param-3-data-type
                                                        ,input buf_tt0-rule-call-param.param-value-integer
                                                        ,input buf_tt0-rule-call-param.call_id
                                                        ).
                run update-ext-system in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                        ,input buf_tt0-rule-call-param.param-2-data-type
                                                        ,input buf_tt0-rule-call-param.param-3-data-type
                                                        ,input buf_tt0-rule-call-param.param-value-integer
                                                        ,input buf_tt0-rule-call-param.call_id
                                                        ).
                find first buf_rule-call-param share-lock where
                          buf_rule-call-param.call#_id = buf_tt0-rule-call-param.call#_id
                      and buf_rule-call-param.codex_id = buf_tt0-rule-call-param.codex_id
                      and buf_rule-call-param.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and buf_rule-call-param.order_id = buf_tt0-rule-call-param.order_id
                      and buf_rule-call-param.param-num = buf_ruledict-param.param-num
                      and buf_rule-call-param.param-name = buf_tt0-rule-call-param.param-name
                      and buf_rule-call-param.p-index = buf_tt0-rule-call-param.p-index
                      no-error.
                if available buf_rule-call-param then do:
                  if buf_tt0-rule-call-param.param-value-character <> buf_rule-call-param.param-value-character then do:
                    run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                                ,input buf_rule-call-param.param-2-data-type
                                                                ,input buf_rule-call-param.param-3-data-type
                                                                ,input buf_rule-call-param.param-value-character
                                                                ,input buf_rule-call-param.call_id).
                  end.
                  if buf_tt0-rule-call-param.param-value-integer <> buf_rule-call-param.param-value-integer then do:
                    run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                    run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                  end.
                end.
              end.
            end.
            if lookup('rule-by-call':U, p-data-completeness) = 0
            and lookup('rp-by-call':U, p-data-completeness) = 0
            and lookup('rule-call-param':U, p-data-completeness) > 0 then do:
              find first buf_rule-call-param share-lock where
                        buf_rule-call-param.call#_id = buf_tt0-rule-call-param.call#_id
                    and buf_rule-call-param.codex_id = buf_tt0-rule-call-param.codex_id
                    and buf_rule-call-param.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                    and buf_rule-call-param.order_id = buf_tt0-rule-call-param.order_id
                    and buf_rule-call-param.param-num = buf_ruledict-param.param-num
                    and buf_rule-call-param.param-name = buf_tt0-rule-call-param.param-name
                    and buf_rule-call-param.p-index = buf_tt0-rule-call-param.p-index
                    no-error.
              if not available buf_rule-call-param then do:
                if v-call#-id = 0 then do:
                  run rul/g-callid.p ( input p-call-type
                                      ,input p-call-id
                                      ,output v-call#-id).
                end.
                create buf_rule-call-param.
                assign
                v-cmp-loc = no
                v-cmp = v-cmp and v-cmp-loc
                .
              end.
              else do:
                if v-call#-id = 0 then do:
                  run rul/g-callid.p ( input p-call-type
                                      ,input p-call-id
                                      ,output v-call#-id).
                end.
                if buf_tt0-rule-call-param.param-2-data-type <> '':U
                and (buf_tt0-rule-call-param.p-index > 0
                or lookup("LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
                or lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) = 0)
                then do:
                  if buf_tt0-rule-call-param.param-value-character <> buf_rule-call-param.param-value-character then do:
                    run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                                ,input buf_rule-call-param.param-2-data-type
                                                                ,input buf_rule-call-param.param-3-data-type
                                                                ,input buf_rule-call-param.param-value-character
                                                                ,input buf_rule-call-param.call_id).
                  end.
                  if buf_tt0-rule-call-param.param-value-integer <> buf_rule-call-param.param-value-integer then do:
                    run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                    run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                  end.
                end.
              end.
              buffer-compare buf_tt0-rule-call-param to
              buf_rule-call-param save result in v-cmp-loc.
              buffer-copy buf_tt0-rule-call-param
              except call#_id
              to buf_rule-call-param
              assign
              buf_rule-call-param.call#_id = v-call#-id
              .
              if not v-cmp-loc and v-run-bush-command then do:
                  run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
              end.
            end.
          end.
        end.
        for each buf_tt0-rule-call-param where
                buf_tt0-rule-call-param.call_id = p-call-id
            and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
            and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
            and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          find first buf_ruledict-param no-lock where
                    buf_ruledict-param.entry-id = buf_Ruledict.entry-id
                and buf_ruledict-param.param-num = buf_tt0-rule-call-param.param-num no-error .
          if not available buf_ruledict-param then do:
            undo _main, return error substitute("Неизвестный параметр № &1 для вызова правила &2:&3" +
                                                "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                , buf_tt0-rule-call-param.param-num
                                                , tt0-rule-call-param.rule_id
                                                , chr(10)
                                                , p-call-id
                                                , tt0-rule-call-param.codex_id
                                                , tt0-rule-call-param.ruleset_id
                                                , tt0-rule-call-param.order_id).
          end.
        end.
        if lookup('rule-by-call':U, p-data-completeness) = 0
        and lookup('rp-by-call':U, p-data-completeness) = 0
        and lookup('rule-call-param':U, p-data-completeness) > 0 then do:
          for each buf_rule-call-param share-lock where
                  buf_rule-call-param.call_id = p-call-id
              and buf_rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_rule-call-param.order_id = tt0-rule-call-param.order_id
          on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
          ON STOP undo _MAIN, return error '':u:
            find first buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.call_id = p-call-id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = tt0-rule-call-param.param-num
              and buf_tt0-rule-call-param.param-name = tt0-rule-call-param.param-name
              and buf_tt0-rule-call-param.p-index = tt0-rule-call-param.p-index
              no-error.
            if not available buf_tt0-rule-call-param then do:
              if v-run-bush-command then do:
                run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
              end.
              delete buf_rule-call-param.
            end.
          end.
        end.
      end.
    end.
  end.
  if lookup('rule-by-call':U, p-data-completeness) > 0
  and lookup('rule-call-param':U, p-data-completeness) > 0
  then do:
    for each buf_rule-by-call where
              buf_rule-by-call.call_id = p-call-id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
      find first tt0-rule-by-call no-lock where
                tt0-rule-by-call.call_id = p-call-id
            and tt0-rule-by-call.codex_id = buf_rule-by-call.codex_id
            and tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
            and tt0-rule-by-call.order_id = buf_rule-by-call.order_id  no-error.
      if not available tt0-rule-by-call then do:
        for each buf_rule-call-param where
              buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          and buf_rule-call-param.call_id = buf_rule-by-call.call_id
          and buf_rule-call-param.order_id = buf_rule-by-call.order_id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          if buf_rule-call-param.p-index > 0
          or lookup("LIST", buf_rule-call-param.param-3-data-type) = 0
          or lookup("SORTED-LIST", buf_rule-call-param.param-3-data-type) = 0
          then do:
            run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                        ,input buf_rule-call-param.param-2-data-type
                                                        ,input buf_rule-call-param.param-3-data-type
                                                        ,input buf_rule-call-param.param-value-character
                                                        ,input buf_rule-call-param.call_id).
            run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                    ,input buf_rule-call-param.param-2-data-type
                                                    ,input buf_rule-call-param.param-3-data-type
                                                    ,input buf_rule-call-param.param-value-integer
                                                    ,input buf_rule-call-param.call_id
                                                    ,buffer buf_rule-call-param
                                                    ).
            run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                    ,input buf_rule-call-param.param-2-data-type
                                                    ,input buf_rule-call-param.param-3-data-type
                                                    ,input buf_rule-call-param.param-value-integer
                                                    ,input buf_rule-call-param.call_id
                                                    ,buffer buf_rule-call-param
                                                    ).
          end.
          if v-run-bush-command then do:
            run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
          end.
          delete buf_rule-call-param.
        end.
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_rule-by-call.rule_id no-error.
        if available buf_rule then do:
          find  current buf_rule exclusive-lock .
        end.
        if v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-by-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-by-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
        delete buf_rule-by-call.
        if available buf_rule then do:
          define variable v-mess as character no-undo .
          v-ok = no.
          run trg/rule-chk.p ( input 'удаление':U
                              ,input buf_rule.rule_id
                              ,output v-ok
                              ,output v-mess
                              ) no-error.
          if not error-status:error
          and not v-ok then do:
            if buf_rule.sts <> integer('-1':U) then do:
              buf_rule.sts = integer('-1':U).
            end.
          end.
        end.
      end.
    end.
    for each tt0-rule-by-call
    where tt0-rule-by-call.call_id = p-call-id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      find first buf_rule-by-call where
                buf_rule-by-call.call_Id = tt0-rule-by-call.call_id
            and buf_rule-by-call.codex_id = tt0-rule-by-call.codex_id
            and buf_rule-by-call.ruleset_id = tt0-rule-by-call.ruleset_id
            and buf_rule-by-call.order_id = tt0-rule-by-call.order_id  no-error .
      if not available buf_rule-by-call then do:
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
      end.
      else do:
        define variable v-rec as recid no-undo .
        v-rec = recid(buf_rule-by-call).
      end.
      run rul/rule-by-call1.p ( input (if not available buf_rule-by-call
                                        then 'ДОБАВЛЕНИЕ':U
                                        else 'ИЗМЕНЕНИЕ':U)
                                ,input yes
                                ,input-output v-rec
                                ,input p-cmd-proc-handle
                                ,input p-cmd-code
                                ,input (if not available buf_rule-by-call
                                        then v-call#-id
                                        else buf_rule-by-call.call#_ID)
                                ,input tt0-rule-by-call.codex_id
                                ,input tt0-rule-by-call.ruleset_id
                                ,input tt0-rule-by-call.order_id
                                ,input tt0-rule-by-call.call_id
                                ,input tt0-rule-by-call.rule_id
                                ,input tt0-rule-by-call.profile_id
                                ,input tt0-rule-by-call.once-more
                                ,input tt0-rule-by-call.is_dynamic
                                ,input tt0-rule-by-call.can-calc
                                ,input tt0-rule-by-call.algo-des) no-error .
      if error-status:error then do:
        UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ).
      end.
      for each buf_rule-call-param where
            buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and buf_rule-call-param.call_id = tt0-rule-by-call.call_id
        and buf_rule-call-param.order_id = tt0-rule-by-call.order_id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
        find first tt0-rule-call-param where
            tt0-rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and tt0-rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and tt0-rule-call-param.call_id = tt0-rule-by-call.call_Id
        and tt0-rule-call-param.order_id = tt0-rule-by-call.order_id
        and tt0-rule-call-param.param-name = buf_rule-call-param.param-name
        and tt0-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
        if not available tt0-rule-call-param then do:
          if v-run-bush-command then do:
            run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
          end.
          delete buf_rule-call-param.
        end.
      end.
      for each tt0-rule-call-param where
            tt0-rule-call-param.call_id = p-call-id
        and tt0-rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and tt0-rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and tt0-rule-call-param.call_id = tt0-rule-by-call.call_Id
        and tt0-rule-call-param.order_id = tt0-rule-by-call.order_id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
        find first buf_rule-call-param where
                  buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
              and buf_rule-call-param.call_id = tt0-rule-by-call.call_Id
              and buf_rule-call-param.order_id = tt0-rule-by-call.order_id
              and buf_rule-call-param.param-name = tt0-rule-call-param.param-name
              and buf_rule-call-param.p-index = tt0-rule-call-param.p-index
              no-error.
        if not available buf_rule-call-param then do:
          if v-call#-id = 0 then do:
            run rul/g-callid.p ( input p-call-type
                                ,input p-call-id
                                ,output v-call#-id).
          end.
          create buf_rule-call-param.
          assign
          v-cmp-loc = no
          v-cmp = v-cmp and v-cmp-loc
          .
        end.
        else do:
          buffer-compare tt0-rule-call-param
          except call#_id to buf_rule-call-param save result in v-cmp-loc.
        end.
        buffer-copy tt0-rule-call-param
        except call#_id
        to buf_rule-call-param
        assign
        buf_rule-call-param.call#_id = v-call#-id
        .
        if not v-cmp-loc and v-run-bush-command then do:
           run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
      end.
    end.
    define variable v-can-run as logical no-undo .
    _rule-by-call:
    for each buf_rule-by-call exclusive-lock where
              buf_rule-by-call.call_id = p-call-id,
      first buf_rule no-lock where
            buf_rule.rule_id = buf_rule-by-call.rule_id
    by buf_rule-by-call.call_Id
    by buf_rule-by-call.codex_id
    by buf_rule-by-call.ruleset_id
    by buf_rule-by-call.order_id
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
      run check-reusable in this-procedure ( input p-call-id
                                              ,input buf_rule-by-call.codex_id
                                              ,input buf_rule-by-call.ruleset_id
                                              ,input buf_rule-by-call.order_id
                                              ,input buf_rule-by-call.profile_id
                                              ,input buf_rule-by-call.rule_id
                                              ,input buf_rule.reusable-params
                                              ,output v-can-run
                                              ).
      if buf_rule-by-call.can-run <> v-can-run
      or (v-can-run = no and buf_rule-by-call.can-calc = yes)
      or (v-can-run = yes and buf_rule-by-call.can-calc = no and not buf_rule-by-call.is_dynamic  )
      then do:
        assign
        v-old-can-run = buf_rule-by-call.can-run
        v-old-can-calc = buf_rule-by-call.can-calc
        buf_rule-by-call.can-run = v-can-run
        buf_rule-by-call.can-calc = (if v-can-run
                                      then (if not buf_rule-by-call.is_dynamic
                                            then yes
                                            else buf_rule-by-call.can-calc)
                                      else no)
        v-cmp-loc = ((v-old-can-run = buf_rule-by-call.can-run)
                      and
                      (v-old-can-calc = buf_rule-by-call.can-calc)
                    )
        .
        if not v-cmp-loc and v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-by-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rule-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-by-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
      end.
    end.
  end.
  if v-create-command then do:
    run send-command in p-cmd-proc-handle
      ( input p-cmd-code
        ,input '':U
        ) no-error .
    if error-status:error then do:
      delete procedure p-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", v-command ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo _main, return error .
    end.
  end.
end.
procedure update-prop-ref-call :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-character as character no-undo .
define input parameter p-call-id as character no-undo .
define variable v-dtm-code as integer no-undo init -1.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-ref-call for ub.prop-ref-call.
_main:
do
on error undo, return error
:
  if p-param-2-data-type begins ('prop-ref':U + "_") then do:
    assign
    v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    find first buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = v-dtm-code
    and buf_prop-ref.sum-id = p-value-character no-error .
    if available buf_prop-ref then do:
      find first buf_prop-ref-call where
                buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
            and buf_prop-ref-call.call_id = p-call-id no-error .
      if not available buf_prop-ref-call then do:
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        create buf_prop-ref-call.
        assign
        buf_prop-ref-call.call_id = p-call-id
        buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
        buf_prop-ref-call.dtm-code = buf_prop-ref.dtm-code
        buf_prop-ref-call.call#_id = v-call#-id
        .
      end.
      find first temp-prop-ref-call where
                temp-prop-ref-call.dt-code = buf_prop-ref.dt-code no-error.
      if not available temp-prop-ref-call then do:
        create temp-prop-ref-call.
        buffer-copy buf_prop-ref-call to temp-prop-ref-call.
      end.
      assign
      temp-prop-ref-call.counter = temp-prop-ref-call.counter + 1
      buf_prop-ref-call.counter = temp-prop-ref-call.counter.
      release temp-prop-ref-call.
      if v-run-bush-command then do:
           run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'prop-ref-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_prop-ref-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'prop-ref-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
      end.
    end.
  end.
end.
end procedure.
procedure delete-prop-ref-call :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-character as character no-undo .
define input parameter p-call-id as character no-undo .
define variable v-dtm-code as integer no-undo init -1.
define variable v-ok as logical no-undo .
define variable v-mwss as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-ref-call for ub.prop-ref-call.
_main:
do
on error undo, return error
:
  if  p-param-2-data-type begins ('prop-ref':U + "_") then do:
    assign
    v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    find first buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = v-dtm-code
    and buf_prop-ref.sum-id = p-value-character no-error .
    if available buf_prop-ref then do:
      find first buf_prop-ref-call where
                buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
            and buf_prop-ref-call.call_id = p-call-id no-error .
      if available buf_prop-ref-call then do:
        buf_prop-ref-call.counter = buf_prop-ref-call.counter - 1.
        if buf_prop-ref-call.counter = 0 then do:
          run rul/pref-chk.p ( input 'удаление':U
                              ,input "ruprcall"
                              ,input buf_prop-ref-call.dtm-code
                              ,input buf_prop-ref-call.dt-code
                              ,output v-ok
                              ,output v-mess) no-error .
          if v-ok then do:
            if v-run-bush-command then do:
                          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'prop-ref-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_prop-ref-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'prop-ref-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
            end.
            delete buf_prop-ref-call.
          end.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure update-dis-rule :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-param-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define variable v-templ-rl-root as integer no-undo.
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable jj as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-curr-field as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
_main:
do
on error undo, return error
:
  if p-param-2-data-type begins ('dis-rule':U + "_")
  then do:
    assign
    v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    case p-call-type:
      when 'dis-card-type':U then do:
        run gen-key-fv in this-procedure ( input p-call-id
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-type =  entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
        v-emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)))
        .
        find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = v-templ-rl-root
        and buf_dis-cfg-rule.pos-type = 'bo':U
        and buf_dis-cfg-rule.table-name = 'dis-dct-rule':U no-error .
        if available buf_Dis-cfg-rule then do:
          find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = p-param-value-integer no-error.
          if available buf_dis-rule then do:
            do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
              assign
              v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
              .
              assign
              v-nonunique = v-nonunique + (if v-nonunique = '':u then '':U else chr(4)) +
                            string(buffer buf_dis-rule:buffer-field(v-curr-field):buffer-value).
            end.
            find first buf_dis-dct-rule where
                  buf_dis-dct-rule.type = v-type
              and buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
              and buf_dis-dct-rule.host-code = buf_dis-rule.host-code
              and buf_dis-dct-rule.obj-type = buf_dis-rule.obj-type
              and buf_dis-dct-rule.obj-code = buf_dis-rule.obj-code
              and buf_dis-dct-rule.pos-type = 'bo':U
              and buf_dis-dct-rule.nonunique = v-nonunique
              and buf_dis-dct-rule.discnt-role = buf_dis-cfg-rule.discnt-role
              no-error .
            if not available buf_dis-dct-rule then do:
              create buf_dis-dct-rule.
              assign
              buf_dis-dct-rule.type = v-type
              buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
              buf_dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
              buf_dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
              buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num
              buf_dis-dct-rule.host-code = buf_dis-rule.host-code
              buf_dis-dct-rule.obj-type = buf_dis-rule.obj-type
              buf_dis-dct-rule.obj-code = buf_dis-rule.obj-code
              buf_dis-dct-rule.pos-type = 'bo':U
              buf_dis-dct-rule.nonunique = v-nonunique
              buf_dis-dct-rule.discnt-role = buf_dis-cfg-rule.discnt-role
              buf_dis-dct-rule.rl-root = buf_dis-rule.rl-root
              .
              if v-run-bush-command then do:
                                          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
              end.
            end.
          end.
        end.
      end.
    end case.
  end.
end.
end procedure.
procedure delete-dis-rule :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define variable v-templ-rl-root as integer no-undo.
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-found as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
_main:
do
on error undo, return error
:
  if  p-param-2-data-type begins ('dis-rule':U + "_") then do:
    assign
    v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    case p-call-type:
      when 'dis-card-type':U then do:
        run gen-key-fv in this-procedure ( input p-call-id
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-type =  entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
        v-emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)))
        .
        v-found = no.
        _buf_tt0-rule-call-param:
        for each buf_tt0-rule-call-param no-lock where
                buf_tt0-rule-call-param.call_id = p-call-id:
          if buf_tt0-rule-call-param.param-2-data-type = p-param-2-data-type
          and buf_tt0-rule-call-param.param-value-integer = p-value-integer
          then do:
            v-found = yes.
            leave _buf_tt0-rule-call-param.
          end.
        end.
        if not v-found then do:
          for each buf_dis-dct-rule where
                    buf_dis-dct-rule.rule-num = p-value-integer
                and buf_dis-dct-rule.templ-rl-root = v-templ-rl-root
                and buf_dis-dct-rule.type = v-type
                and buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
          on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo , return error substitute( "&1. stop", vss-workfile )
          on endkey undo , return error substitute( "&1. endkey", vss-workfile )
          :
            if v-run-bush-command then do:
                          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
            end.
            delete buf_dis-dct-rule.
          end.
        end.
      end.
    end case.
  end.
end.
end procedure.
procedure update-ext-system :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-param-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define variable v-resource-id as character no-undo .
define buffer buf_ext-system for ub.ext-system.
_main:
do
on error undo, return error
:
  if p-param-2-data-type =  'ext-system':U
  then do:
    case p-call-type:
      when 'dis-card-type':U then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = p-param-value-integer
              and buf_ext-system.db-num = 0.
        run gen-key-rec in this-procedure (
                                            input 'ext-system':U
                                           ,input (buffer buf_ext-system:handle)
                                           ,output v-resource-id).
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        run who-lk_make-some-lk in this-procedure (
                                                   input v-resource-id
                                                  ,input p-call-id
                                                  ,input v-call#-id
                                                  ,input 'update-delete':U
                                                  ,input g#db-num
                                                  ,input substitute("&1: Параметр работы алгоритма", calldscr(p-call-id))
                                                  ,input ""
                                                  ).
      end.
    end case.
  end.
end.
end procedure.
procedure delete-ext-system :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define variable v-resource-id as character no-undo .
define buffer buf_ext-system for ub.ext-system.
_main:
do
on error undo, return error
:
  if  p-param-2-data-type = 'ext-system':U then do:
    case p-call-type:
      when 'dis-card-type':U then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = p-value-integer
              and buf_ext-system.db-num = 0 no-error.
        if not available buf_Ext-system then return.
        run gen-key-rec in this-procedure (
                                            input 'ext-system':U
                                           ,input (buffer buf_ext-system:handle)
                                           ,output v-resource-id).
        run who-lk_delete-some-lk in this-procedure (
                                                   input v-resource-id
                                                  ,input p-call-id
                                                  ,input 'update-delete':U
                                                  ,input g#db-num
                                                  ).
      end.
    end case.
  end.
end.
end procedure.
procedure delete-from-rp-by-call:
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
_main:
do
on error undo, return error
:
  for each buf_rule-by-call share-lock where
         buf_rule-by-call.call_id = p-call-id
     and buf_rule-by-call.profile_id = p-profile-id
     and buf_rule-by-call.once-more = p-once-more
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    for each buf_rule-call-param share-lock where
           buf_rule-call-param.call_id = buf_rule-by-call.call_id
       and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
       and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
       and buf_rule-call-param.order_id = buf_rule-by-call.order_id
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
        if buf_rule-call-param.p-index > 0
        or lookup("LIST", buf_rule-call-param.param-3-data-type) = 0
        or lookup("SORTED-LIST", buf_rule-call-param.param-3-data-type) = 0
        then do:
          run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                      ,input buf_rule-call-param.param-2-data-type
                                                      ,input buf_rule-call-param.param-3-data-type
                                                      ,input buf_rule-call-param.param-value-character
                                                      ,input buf_rule-call-param.call_id).
          run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                  ,input buf_rule-call-param.param-2-data-type
                                                  ,input buf_rule-call-param.param-3-data-type
                                                  ,input buf_rule-call-param.param-value-integer
                                                  ,input buf_rule-call-param.call_id
                                                  ,buffer buf_rule-call-param
                                                  ).
          run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                  ,input buf_rule-call-param.param-2-data-type
                                                  ,input buf_rule-call-param.param-3-data-type
                                                  ,input buf_rule-call-param.param-value-integer
                                                  ,input buf_rule-call-param.call_id
                                                  ,buffer buf_rule-call-param
                                                  ).
        end.
        if v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
    end.
    if v-run-bush-command then do:
          run add-dump in p-cmd-proc-handle                                                                              (input p-cmd-code                                                                                            ,input 'rule-by-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                       if v-create-command then delete procedure p-cmd-proc-handle.                                                 undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-by-call':U                                                                                                ,p-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    end.
   end.
end.
end procedure.
procedure check-list-unique :
define input parameter p-call-id as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-param-data-type as character no-undo .
define variable v-current-index as integer no-undo .
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf2_tt0-rule-call-param for tt0-rule-call-param.
find first buf_tt0-rule-call-param where
        buf_tt0-rule-call-param.call_id = p-call-id
    and buf_tt0-rule-call-param.codex_id = p-codex-id
    and buf_tt0-rule-call-param.ruleset_id = p-ruleset-id
    and buf_tt0-rule-call-param.order_id = p-order-id
    and buf_tt0-rule-call-param.param-name = p-param-name
    and buf_tt0-rule-call-param.p-index > 0
    no-error.
do while available buf_tt0-rule-call-param:
  v-current-index = buf_tt0-rule-call-param.p-index.
  for each buf2_tt0-rule-call-param where
        buf2_tt0-rule-call-param.call_id = p-call-id
    and buf2_tt0-rule-call-param.codex_id = p-codex-id
    and buf2_tt0-rule-call-param.ruleset_id = p-ruleset-id
    and buf2_tt0-rule-call-param.order_id = p-order-id
    and buf2_tt0-rule-call-param.param-name = p-param-name
    and buf2_tt0-rule-call-param.p-index > buf_tt0-rule-call-param.p-index   :
    if buffer buf_tt0-rule-call-param:handle:buffer-field( substitute("param-value-&1", p-param-data-type)):buffer-value =
       buffer buf2_tt0-rule-call-param:handle:buffer-field( substitute("param-value-&1", p-param-data-type)):buffer-value
    then do:
      undo, return error ''.
    end.
  end.
  find first buf_tt0-rule-call-param where
          buf_tt0-rule-call-param.call_id = p-call-id
      and buf_tt0-rule-call-param.codex_id = p-codex-id
      and buf_tt0-rule-call-param.ruleset_id = p-ruleset-id
      and buf_tt0-rule-call-param.order_id = p-order-id
      and buf_tt0-rule-call-param.param-name = p-param-name
      and buf_tt0-rule-call-param.p-index > v-current-index
      no-error.
end.
end procedure.
