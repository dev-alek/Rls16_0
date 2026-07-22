block-level on error undo, throw.
define input parameter p-pchain-type as character no-undo .
define input parameter p-pchain-id as character no-undo .
define input parameter p-start-from as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-txt-cont-handle as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр правил, запускающихся в rum, для конкретного процесса и конкретного вызова".
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
define temp-table temp-pchain-link-rule no-undo
field pchain-type as character
field pchain-id as character
field start-from as integer
field link-id as integer
field codex_id as integer
field ruleset_id as integer
field run-DB0 as integer
field run-RDB as integer
field order_id as integer
field rule_id as integer
field profile_id as integer
field once-more as integer
field can-calc as logical
field can-run as logical
field link-btwn-profiles as integer
index pi is unique primary
pchain-type
pchain-id
start-from
link-id
order_id
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-string no-undo
field v-string as character
field string-num as integer
index pi is unique primary string-num.
procedure temp-string_clear :
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    for each buf_temp-string
    on error undo, return error
    :
      delete buf_temp-string.
    end.
  end.
end procedure.
procedure temp-string_write :
  define input  parameter p-v-string    as character no-undo .
  define variable v-string-num as integer no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find last buf_temp-string no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
      buf_temp-string.string-num     = 1
      buf_temp-string.v-string       = p-v-string
      .
    end.
    else do:
      v-string-num = buf_temp-string.string-num.
      create buf_temp-string .
      assign
      buf_temp-string.string-num = v-string-num + 1
      buf_temp-string.v-string = p-v-string
      .
    end.
  end.
end procedure.
procedure temp-string_read :
  define input  parameter p-string-num    as integer   no-undo .
  define output parameter p-v-string      as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
      where buf_temp-string.string-num     = p-string-num
      no-error .
    if available buf_temp-string then do:
      assign
        p-v-string = buf_temp-string.v-string
      .
    end.
    else do:
      assign
        p-v-string = '':U
      .
    end.
  end.
end procedure.
procedure temp-string_append :
  define input  parameter p-string-num  as integer   no-undo .
  define input  parameter p-v-string    as character no-undo .
  define input  parameter p-append-char as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
         where buf_temp-string.string-num = p-string-num
      no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
        buf_temp-string.string-num  = p-string-num
        buf_temp-string.v-string    = p-v-string
      .
    end.
    else do:
        assign
        buf_temp-string.v-string = buf_temp-string.v-string + p-append-char + p-v-string
        .
    end.
  end.
end procedure.
procedure temp-string_get-last-num:
define output parameter p-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
find last buf_temp-string no-error.
if available buf_temp-string then do:
  p-string-num = buf_temp-string.string-num.
end.
end procedure.
procedure temp-string_delete-range:
define input parameter p-first-string-num  as integer   no-undo .
define input parameter p-last-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
for each buf_temp-string where
        buf_temp-string.string-num >= p-first-string-num
    and buf_temp-string.string-num <= p-last-string-num:
  delete buf_temp-string.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-rule-call-params :
define input parameter p-mode as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-handle as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-string as character no-undo .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run temp-string_write in p-handle ( input "ПАРАМЕТРЫ").
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
  _rr:
  for each buf_rule-call-param no-lock where
          buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id:
    if p-once-more >= 0 and
    buf_rule-call-param.once-more <> p-once-more then next.
    v-string = '':U.
    if lookup("LIST", buf_rule-call-param.param-3-data-type) > 0 then do:
      if buf_rule-call-param.p-index = 0 then do:
        assign
        v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
        run temp-string_write in p-handle ( input v-string).
        next _rr.
      end.
      else do:
        assign
        v-string = fill( chr(32), length(buf_rule-call-param.param-label) + 2).
      end.
    end.
    else do:
      assign
      v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
    end.
    CASE buf_rule-call-param.param-data-type:
      when 'character':U then do:
        v-string = v-string + buf_rule-call-param.param-value-character.
      end.
      when 'date':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-date, "99/99/9999").
      end.
      when 'logical':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-logical, "ДА/НЕТ").
      end.
      when 'decimal':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-decimal).
      end.
      when 'integer':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-integer).
      end.
    END CASE.
    run temp-string_write in p-handle ( input v-string).
  end.
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-ruledict-params :
define input parameter p-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule for ub.rule.
define variable v-string as character no-undo .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_rule no-lock where
            buf_rule.rule_id = p-rule-id.
  find first buf_ruledict no-lock where
            buf_ruledict.entry-type = 'rule':U
        and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  run temp-string_write in this-procedure ( input "ПАРАМЕТРЫ").
  if p-mode = "text" then do:
    run temp-string_write in this-procedure ( input "").
  end.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id:
    assign
    v-string = substitute("&1 (&2) (&3)"
                          , buf_ruledict-param.param-label
                          , buf_ruledict-param.param-data-type
                          , buf_ruledict-param.param-name).
    run temp-string_write in this-procedure ( input v-string).
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-edge no-undo
field from-link-id as integer
field to-link-id as integer
field from-order_id as integer
field to-order_id as integer
field edge-type as character
index pi is unique primary
from-link-id
to-link-id
from-order_id
to-order_id
index isearch
to-link-id
to-order_id
.
function break-string-for-dot returns character (input p-string as character, input p-line-length AS INTEGER):
define variable v-string as character no-undo .
define variable v-output-string as character no-undo .
define variable v-entry as character no-undo .
define variable v-index as integer no-undo .
v-string = p-string.
v-output-string = p-string.
do while length(v-string) > p-line-length :
  ASSIGN
  v-entry = substring(v-string, 1, p-line-length)
  v-index = r-index(v-entry, chr(32)).
  if v-index > 0
  and v-index <= p-line-length then do:
     assign
     v-output-string = v-output-string + substring(v-entry, 1, v-index - 1)  + '\N'.
     v-string = substring(v-string, v-index + 1)
     no-error.
     if error-status:error then leave.
  end.
  ELSE DO:
      assign
      v-output-string = v-output-string + v-entry.
      v-string = substring(v-string, 71)
      no-error.
  END.
end.
return v-output-string.
end.
define variable v-can-calc-string as character no-undo .
define variable v-label as character no-undo .
define variable v-name as character no-undo .
define variable v-node-name as character no-undo .
define variable v-proc-name as character no-undo .
define variable v-name-full as character no-undo .
define variable err-file as character no-undo .
define variable res as character no-undo .
define variable v-cmdln as character no-undo .
define variable v-before-string-num as integer no-undo .
define variable v-after-string-num as integer no-undo .
define variable v-param-string-num as integer no-undo .
define variable v-prev-node-name as character no-undo .
define variable v-fill-color as character no-undo .
define variable v-blank as integer no-undo .
define variable v-first-node-name as character no-undo .
define variable v-last-node-name as character no-undo .
define variable v-short-file-name as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-cmd           as character                no-undo .
DEFINE VARIABLE v-file-name-dot           as character                no-undo .
DEFINE VARIABLE v-file-name-gif           as character                no-undo .
define variable v-file-name-html          as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-prev-link-id as integer no-undo .
define variable v-prev-order-id as integer no-undo .
define variable v-handle as handle no-undo .
define buffer buf_rule-process for ub.rule-process .
define buffer buf_temp-pchain-link-rule for temp-pchain-link-rule .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule for ub.rule.
define buffer buf_ruleset for ub.ruleset.
define buffer buf_TEMP-STRING  for temp-string.
define buffer buf_temp-edge for temp-edge.
define stream outstream.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  for each buf_temp-pchain-link-rule:
    delete buf_temp-pchain-link-rule.
  end.
  if p-txt-cont-handle = ?
  or not valid-handle(p-txt-cont-handle)
  then do:
    v-handle = this-procedure:handle.
  end.
  else do:
    v-handle = p-txt-cont-handle.
  end.
  run temp-string_clear in v-handle .
  if p-profile-id > 0 then do:
    find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = p-profile-id.
  end.
  case p-pchain-type:
    when 'dis-card-type':U then do:
        v-proc-name = entry (lookup (p-pchain-id, 'sale-close,sale-delete,trn-doc-close,trn-doc-delete,sale-xml-import,text-import,text-export,one-card-recalc,one-card-check,one-card-add,batch-card-recalc,stop-list-import,payment-on-card,fin-doc-on-card,delete-fin-doc-from-card':U) + 1, ',' + 'Закрытие продажи на факт,Удаление закрытой продажи,Закрытие накл. с ДК на факт,Удаление накл. с ДК,Импорт продаж в XML виде,Импорт данных в текст.виде,Экспорт данных в текст.виде,Пересчет по одной карте,Проверка одной карты,Добавление одной карты,Пересчет карт,Импорт стоплиста,Внесение средств на карту,Внес.пл-жа на карту через сист.взаиморасчетов,Удал.пл-жа с карты через сист.взаиморасчетов':U).
    end.
  end case.
  v-name-full =  substitute("&1: выполнение процесса &2 &3"
                                          , (if p-call-id = '':U
                                              then buf_rule-profile.name
                                              else calldscr( p-call-id))
                                          , v-proc-name
                                          , (if p-start-from = 0
                                              then "Актив.сторона-ГБД"
                                              else (if p-start-from = 1
                                                    then "Актив.сторона-УБД"
                                                    else "")
                                                    )
                                          ).
  for each buf_rule-process where
          buf_rule-process.pchain-type = p-pchain-type
      and buf_rule-process.pchain-id = p-pchain-id
      and buf_rule-process.start-from = p-start-from:
    if p-call-id = '':u then do:
      for each buf_rule-by-profile no-lock where
              buf_rule-by-profile.profile_id = p-profile-id
          and buf_rule-by-profile.codex_id = buf_rule-process.codex_id
          and buf_rule-by-profile.ruleset_id = buf_rule-process.ruleset_id:
        create buf_temp-pchain-link-rule.
        buffer-copy buf_rule-process to buf_temp-pchain-link-rule.
        buffer-copy buf_rule-by-profile to buf_temp-pchain-link-rule
        assign
        buf_temp-pchain-link-rule.order_id = buf_rule-by-profile.rp_order_id
        buf_temp-pchain-link-rule.can-calc = not (buf_rule-by-profile.is_dynamic)
        .
      end.
    end.
    else do:
      for each buf_rule-by-call no-lock where
          buf_rule-by-call.call_id = p-call-id
      and buf_rule-by-call.codex_id = buf_rule-process.codex_id
      and buf_rule-by-call.ruleset_id = buf_rule-process.ruleset_id:
        if p-profile-id > 0
        and buf_rule-by-call.profile_id <> p-profile-id then next.
        if p-once-more >= 0
        and buf_rule-by-call.once-more <> p-once-more then next.
        create buf_temp-pchain-link-rule.
        buffer-copy buf_rule-process to buf_temp-pchain-link-rule.
        buffer-copy buf_rule-by-call to buf_temp-pchain-link-rule.
      end.
    end.
  end.
  case p-mode:
    when "text"
    or when "text-temp"
    then do:
      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if first-of(buf_temp-pchain-link-rule.link-id) then do:
          find first buf_ruleset no-lock where
                    buf_ruleset.codex_id = buf_temp-pchain-link-rule.codex_id
                and buf_ruleset.ruleset_id = buf_temp-pchain-link-rule.ruleset_id.
          run temp-string_write in v-handle ( input fill("=", 80)).
          run temp-string_write in v-handle ( input  substitute("&1:   &2"
                                                                      ,(if buf_temp-pchain-link-rule.run-db0 > 0
                                                                        then "ГБД"
                                                                        else "УБД")
                                                                      ,CAPS(buf_ruleset.name))).
        end.
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_temp-pchain-link-rule.rule_id.
        if p-call-id = '':U then do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = "[Вкл/Выкл] ".
          end.
          else do:
            v-can-calc-string = '':U.
          end.
        end.
        else do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = '[Выкл] ':U.
          end.
          else do:
            v-can-calc-string = '[Вкл] ':U.
          end.
        end.
        if p-call-id = '':U then do:
          run temp-string_write in v-handle ( input substitute("Правило &1", buf_rule.rule_id)).
        end.
        else do:
          run temp-string_write in v-handle ( input substitute("Правило &1, Профайл &2"
                                                                    , buf_rule.rule_id
                                                                    , buf_temp-pchain-link-rule.profile_id
                                                                    )).
        end.
        run temp-string_write in v-handle ( input substitute("&1&2&3&4"
                                                                  ,v-can-calc-string
                                                                  ,buf_rule.name
                                                                  ,chr(10)
                                                                  ,buf_rule.documentation)).
        if p-call-id = '':U then do:
          RUN display-ruledict-params IN v-handle (
                                                           input p-mode
                                                          ,input buf_rule.rule_id).
        end.
        else do:
          if p-mode = "text" then do:
          RUN display-rule-call-params IN THIS-PROCEDURE (
                                                             input p-mode
                                                            ,INPUT buf_temp-pchain-link-rule.codex_id
                                                            ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                            ,INPUT p-call-id
                                                            ,input p-once-more
                                                            ,INPUT buf_temp-pchain-link-rule.order_id
                                                            ,input v-handle
                                                            ).
        end.
          if p-mode = "text-temp" then do:
            RUN display-rule-call-params IN v-handle (
                                                              input p-mode
                                                              ,INPUT buf_temp-pchain-link-rule.codex_id
                                                              ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                              ,INPUT p-call-id
                                                              ,input p-once-more
                                                              ,INPUT buf_temp-pchain-link-rule.order_id
                                                              ,input v-handle
                                                              ).
          end.
        end.
        if last-of(buf_temp-pchain-link-rule.link-id) then do:
          run temp-string_write in v-handle ( input fill(chr(10), 2)).
        end.
        else do:
          run temp-string_write in v-handle ( input fill(chr(10), 1)).
        end.
      end.
      if v-handle = this-procedure:handle then do:
      run gbl/notese.w ( INPUT THIS-PROCEDURE:HANDLE
                          ,input v-name-full).
    end.
    end.
    when "graph" then do:
      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if buf_temp-pchain-link-rule.link-btwn-profiles >= 0 then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-link-id = v-prev-link-id
          buf_temp-edge.to-link-id   = buf_temp-pchain-link-rule.link-id
          buf_temp-edge.from-order_id = v-prev-order-id
          buf_temp-edge.to-order_id = buf_temp-pchain-link-rule.order_id
          .
        end.
        assign
        v-prev-link-id = buf_temp-pchain-link-rule.link-id
        v-prev-order-id = buf_temp-pchain-link-rule.order_id
        .
      end.
      run temp-string_write in this-procedure ( input substitute("digraph ruleproc ~{"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("compaund=true;"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("rankdir=TB;"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("ratio=auto;"
                                                                )).
      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if first-of(buf_temp-pchain-link-rule.link-id) then do:
          find first buf_ruleset no-lock where
                    buf_ruleset.codex_id = buf_temp-pchain-link-rule.codex_id
                and buf_ruleset.ruleset_id = buf_temp-pchain-link-rule.ruleset_id.
           run temp-string_write in this-procedure ( input substitute("subgraph cluster&1_&2 ~{"
                                                                     , buf_temp-pchain-link-rule.codex_id
                                                                     , buf_temp-pchain-link-rule.ruleset_id
                                                                     )).
           run temp-string_write in this-procedure ( input substitute("node  [style=filled, fontsize=12];")).
          run temp-string_write in this-procedure ( input substitute('nodesep=0.30;')).
          run temp-string_write in this-procedure ( input substitute('ranksep=0.30;')).
        end.
        v-node-name = substitute("n&1_&2"
                                  , buf_temp-pchain-link-rule.link-id
                                  , buf_temp-pchain-link-rule.order_id).
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_temp-pchain-link-rule.rule_id.
        if p-call-id = '':U then do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = "[Вкл/Выкл] ".
            v-fill-color = "yellow".
          end.
          else do:
            v-can-calc-string = '':U.
            v-fill-color = "palegreen".
          end.
        end.
        else do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = '[Выкл] ':U.
            v-fill-color = "lightgrey".
          end.
          else do:
            v-can-calc-string = '[Вкл] ':U.
            v-fill-color = "palegreen".
          end.
        end.
        if p-call-id = '':U then do:
          v-label = substitute("Правило &1", buf_rule.rule_id).
        end.
        else do:
          v-label = substitute("Правило &1, Профайл &2"
                              , buf_rule.rule_id
                              , buf_temp-pchain-link-rule.profile_id
                              ).
        end.
        v-label = substitute("&1&2&3&4&5&6"
                            ,v-label
                            ,"\n"
                            ,v-can-calc-string
                            ,buf_rule.name
                            ,  "\n"
                            ,buf_rule.documentation).
        run temp-string_write in this-procedure ( input substitute('&1 [label="&2", fillcolor=&3, shape=box, style=filled, group=&1];'
                                                                    ,v-node-name
                                                                    ,v-label
                                                                    ,v-fill-color
                                                                    )).
        run temp-string_get-last-num in this-procedure ( output v-before-string-num).
        if p-call-id = '':U then do:
          v-blank = 1.
          RUN display-ruledict-params IN THIS-PROCEDURE (   input p-mode
                                                          ,input buf_rule.rule_id).
        end.
        else do:
          v-blank = 2.
          if p-mode = "text" then do:
          RUN display-rule-call-params IN THIS-PROCEDURE (
                                                             input p-mode
                                                            ,INPUT buf_temp-pchain-link-rule.codex_id
                                                            ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                            ,INPUT p-call-id
                                                            ,input p-once-more
                                                            ,INPUT buf_temp-pchain-link-rule.order_id
                                                            ,input v-handle
                                                            ).
        end.
          if p-mode = "text-temp" then do:
            RUN display-rule-call-params IN v-handle (
                                                              input p-mode
                                                              ,INPUT buf_temp-pchain-link-rule.codex_id
                                                              ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                              ,INPUT p-call-id
                                                              ,input p-once-more
                                                              ,INPUT buf_temp-pchain-link-rule.order_id
                                                              ,input v-handle
                                                              ).
          end.
        end.
        run temp-string_get-last-num in this-procedure ( output v-after-string-num).
        v-prev-node-name = substitute("&1", v-node-name).
        if (v-after-string-num - v-before-string-num) > v-blank then do:
          run temp-string_get-last-num in this-procedure ( output v-param-string-num).
          run temp-string_write in this-procedure ( input substitute('p&1 [shape=record,label="~{'
                                                                     ,v-node-name
                                                                     )).
          for each buf_temp-string where
                  buf_temp-string.string-num > v-before-string-num
             and buf_temp-string.string-num <= v-after-string-num
          break
          by buf_temp-string.string-num:
            run temp-string_read in this-procedure (
                                                      input buf_temp-string.string-num
                                                      ,output v-label).
            if v-label > '':U then do:
              run temp-string_append in this-procedure (
                                                        input (v-param-string-num + 1)
                                                        ,input substitute("<f&1>&2&3"
                                                                          ,buf_temp-string.string-num
                                                                          ,replace(v-label, "|", "/")
                                                                          ,(if last(buf_temp-string.string-num)
                                                                            then ''
                                                                            else "|")
                                                                          )
                                                        ,input '':U).
           end.
           run temp-string_delete-range in this-procedure ( input buf_temp-string.string-num
                                                            ,input buf_temp-string.string-num).
          end.
          run temp-string_append in this-procedure (
                                                    input v-param-string-num + 1
                                                   ,input substitute('~}"];')
                                                    ,input '').
          run temp-string_write in this-procedure ( input substitute('~{rank=same; p&1; &1;~}'
                                                                    ,v-node-name
                                                                      )).
        end.
        else do:
           run temp-string_delete-range in this-procedure ( input (v-before-string-num + 1)
                                                           ,input v-after-string-num
                                                           ).
        end.
        find first buf_temp-edge where
                  buf_temp-edge.to-link-id = buf_temp-pchain-link-rule.link-id
              and buf_temp-edge.to-order_id = buf_temp-pchain-link-rule.order_id no-error.
        if available buf_temp-edge
        and buf_temp-edge.from-link-id > 0
        then do:
           run temp-string_write in this-procedure ( input substitute("n&1_&2:s->n&3_&4:n [weight=1000000];"
                                                                       ,buf_temp-edge.from-link-id
                                                                       ,buf_temp-edge.from-order_id
                                                                       ,buf_temp-edge.to-link-id
                                                                       ,buf_temp-edge.to-order_id
                                                                         )).
        end.
        if last-of(buf_temp-pchain-link-rule.link-id) then do:
           v-label = substitute("&1:   &2"
                                ,(if buf_temp-pchain-link-rule.run-db0 > 0
                                  then "ГБД"
                                  else "УБД")
                                ,CAPS(buf_ruleset.name)).
           run temp-string_write in this-procedure ( input substitute('label ="&1";'
                                                                      ,v-label)).
           run temp-string_write in this-procedure ( input "~}").
        end.
      end.
      run temp-string_write in this-procedure ( input "~}").
      v-name = substitute( "&1_&2_3_&4_5"
                        ,p-pchain-type
                        ,p-pchain-id
                        ,replace(p-call-id, chr(3), "")
                        ,p-profile-id).
      output stream outstream to value( v-name  + ".dot") convert target "UTF-8" .
      for each buf_temp-string
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      :
        put stream outstream unformatted buf_temp-string.v-string chr(10).
      end.
      output stream outstream close.
      run gbl/_tmpfile.p ( input ""
                          ,input  ""
                          ,output err-file) .
      assign
      v-short-file-name = v-name + ".dot"
      .
      run gbl/filename.p (
                    input  v-short-file-name
                    ,output v-file-name-dot
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        message
        return-value
        view-as alert-box ERROR.
        return.
      end.
      run rep/killspac.p ( input-output v-file-name-dot).
      assign
      v-file-name-gif = replace(v-file-name-dot, ".dot", ".gif")
      .
      assign
      v-short-file-name = "exe/graphviz/dot.exe".
      run gbl/filename.p (
                    input  v-short-file-name
                    ,output v-file-name-cmd
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        message
        return-value
        view-as alert-box ERROR.
        return.
      end.
      assign
      err-file = err-file + ".err":u
      v-cmdln = substitute('"&1" -Tgif &2 -o &3 -Gcharset=UTF-8 > &4'
                          ,v-file-name-cmd
                          ,v-file-name-dot
                          ,v-file-name-gif
                          ,err-file
                          ).
      .
      run gbl/syn.p
        (input v-cmdln
        ,input "":U
        ,input "Ждите! Идет форматирование файла..."
        ,output res
        ) no-error .
      run waitfram-hide in this-procedure .
      run gbl/filename.p (
                    input  v-file-name-gif
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        message
        return-value
        view-as alert-box ERROR.
        return.
      end.
      run rep/killspac.p ( input-output v-full-path).
      v-file-name-html = replace(v-file-name-dot, ".dot", ".html").
      output stream Outstream to value(v-file-name-html).
      put stream Outstream unformatted
      substitute('<IMG SRC="&1.gif" ALT="&2">', v-name, v-name-full)
      skip.
      output stream Outstream close.
      run gbl/open_url.p ( input  v-file-name-html) no-error .
      if search("grafdisp.dbg") = ? then do:
        os-delete value(v-file-name-dot).
      end.
      os-delete value(err-file).
    end.
    otherwise do:
      message
      substitute("Неверный параметр p-mode=&1 при вызове показа процесса", p-mode)
      view-as alert-box .
    end.
  end case.
end.
PROCEDURE request-add-line :
DEFINE INPUT PARAMETER p-notes-handle AS HANDLE NO-UNDO.
DEFINE BUFFER buf_temp-string FOR temp-string.
for each buf_temp-string:
    RUN add-line IN p-notes-handle ( INPUT buf_temp-string.v-string).
    RUN add-line IN p-notes-handle ( INPUT chr(10)).
  end.
END PROCEDURE.
