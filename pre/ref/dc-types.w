DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE NEW SHARED BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER paremitent-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER parobj-code like ub.clients.obj-code no-undo.
DEFINE input-OUTPUT PARAMETER p-rid-list As char NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник типов дисконтных карт " .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ri as recid no-undo.
define variable v-is-dc as character no-undo .
define variable v-conf-type as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE rule-proc-option AS CHARACTER NO-UNDO.
FUNCTION get-dflt-dct-rule RETURNS CHARACTER
  (
     INPUT p-emitent-host-code AS INTEGER
    ,INPUT p-type AS CHARACTER
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER
    ,INPUT p-discnt-role AS CHARACTER)  FORWARD.
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer)  FORWARD.
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, parv-rid-list as character  )  FORWARD.
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER )  FORWARD.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.
DEFINE MENU MENU-b-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Схема"         .
DEFINE MENU menu-b-ruleproc
       MENU-ITEM m_rpoc_text    LABEL "Текст"
       MENU-ITEM m_rpoc_graph   LABEL "Графика"       .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-disc
     LABEL "Пр-ла скидок"
     SIZE 12 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON B-mask
     LABEL "&Маски"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-params
     LABEL "Пар-ры"
     SIZE 10 BY 1.
DEFINE BUTTON b-prop-ref
     LABEL "Итоги/Срезы"
     SIZE 15 BY 1.
DEFINE BUTTON b-rule
     LABEL "Правило"
     SIZE 10 BY 1.
DEFINE BUTTON b-ruleproc
     LABEL "Процессы"
     SIZE 12 BY 1.
DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.17
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.88 BY 1 NO-UNDO.
DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Определенные пользователем", 2
     SIZE 36 BY .75 NO-UNDO.
DEFINE QUERY BR-dctype FOR
      x_dis-card-type SCROLLING.
DEFINE QUERY br-profile FOR
      X_rp-by-call SCROLLING.
DEFINE QUERY br-rule-by-call FOR
      X_rule-by-call,
      X_rule-profile SCROLLING.
DEFINE BROWSE BR-dctype
  QUERY BR-dctype DISPLAY
      get-mark(recid(X_dis-card-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_dis-card-type.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
X_dis-card-type.emitent-host-code COLUMN-LABEL "Код!эмитента" FORMAT ">>>>99999":U
get-emitent(X_dis-card-type.emitent-host-code) COLUMN-LABEL "Эмитент" FORMAT "X(15)":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                    ,INPUT X_dis-card-type.type
                    ,INPUT X_dis-card-type.host-code
                    ,INPUT X_dis-card-type.obj-type
                    ,INPUT X_dis-card-type.obj-code
                    ,INPUT 'def-pcnt':U)
 COLUMN-LABEL "%скидки!по умолч!на товар" FORMAT "X(7)":U
X_dis-card-type.d-pcnt-byshop COLUMN-LABEL "Скидка!по!объ./фирм." FORMAT "+/":U
X_dis-card-type.dflt-credit-card COLUMN-LABEL "Кре!дит!ная" FORMAT "+/":U
X_dis-card-type.lim-kr FORMAT ">>>,>>>,>>>,>>9.99":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                  ,INPUT X_dis-card-type.type
                  ,INPUT X_dis-card-type.host-code
                  ,INPUT X_dis-card-type.obj-type
                  ,INPUT X_dis-card-type.obj-code
                  ,INPUT 'def-cash-pcnt':U)
COLUMN-LABEL "%скидки!по умолч!на итог" FORMAT "X(7)":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                ,INPUT X_dis-card-type.type
                ,INPUT X_dis-card-type.host-code
                ,INPUT X_dis-card-type.obj-type
                ,INPUT X_dis-card-type.obj-code
                ,input 'def-categ':U)
COLUMN-LABEL "кате!гория!по умолч" FORMAT "X(4)":U
entry (lookup (string(X_dis-card-type.dflt-d-pcnt-method), '1,2,3':U), 'Товар,Итог_чека,Товары_и_итог_чека':U) COLUMN-LABEL "Использ.скидки" FORMAT "X(12)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.
DEFINE BROWSE br-profile
  QUERY br-profile NO-LOCK DISPLAY
      X_rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9"
get-profile-name ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Название" FORMAT "X(255)"
get-profile-dynamic ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
X_rp-by-call.once-more COLUMN-LABEL "№!привязки" FORMAT ">9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.88
         TITLE "Алгоритмы" ROW-HEIGHT-CHARS .67.
DEFINE BROWSE br-rule-by-call
  QUERY br-rule-by-call NO-LOCK DISPLAY
      X_rule-by-call.can-calc COLUMN-LABEL "Включен?" FORMAT "+/":U
X_rule-by-call.algo-des FORMAT "X(255)":U COLUMN-LABEL "Описание алгоритма/правила" WIDTH 56
X_rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое" FORMAT "+/":U
X_rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>9":U WIDTH 7
X_rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>9":U width 7
X_rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
X_rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>>>>>>9":U WIDTH 9
X_rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.88
         FONT 4
         TITLE "Правила" ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     B-add AT ROW 1 COL 24
     B-lookup AT ROW 1 COL 34
     B-chg AT ROW 1 COL 44
     B-del AT ROW 1 COL 54 WIDGET-ID 16
     b-prop-ref AT ROW 1 COL 64 WIDGET-ID 8
     b-disc AT ROW 1 COL 79 WIDGET-ID 10
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-mask AT ROW 2 COL 64
     b-ruleproc AT ROW 2 COL 79 WIDGET-ID 14
     BR-dctype AT ROW 3.46 COL 1
     Rs-algo-profile AT ROW 12.5 COL 1.5 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 12.5 COL 29 NO-LABEL
     b-rule AT ROW 12.5 COL 65
     b-params AT ROW 12.5 COL 75 WIDGET-ID 6
     B-ruleset AT ROW 12.5 COL 85 WIDGET-ID 12
     br-rule-by-call AT ROW 13.5 COL 1
     br-profile AT ROW 13.5 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 21.5 COL 1 NO-LABEL
     mark-num AT ROW 2.17 COL 2.88 NO-LABEL
     SPACE(86.24) SKIP(20.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Типы дисконтных карт"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-rule:HANDLE.
ASSIGN
       b-ruleproc:POPUP-MENU IN FRAME Dialog-Frame       = MENU menu-b-ruleproc:HANDLE.
ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-dc-type_input-deletion-updating':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if NOT glog then
  return no-apply .
  ri = ?.
  run ref/dc-typei.w (  input parparentproc
                    ,input 'ДОБАВЛЕНИЕ':U
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input-output ri ).
  if ri <> ? then do:
    run OpenBr in this-procedure .
    reposition br-dctype to recid ri no-error.
    apply "ENTRY" to br-dctype.
    apply "VALUE-CHANGED" to br-dctype.
  end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  define variable cur-ri as recid no-undo.
  define variable glog as logical no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-dc-type_input-deletion-updating':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    If available X_dis-card-type then do:
        cur-ri = recid( X_dis-card-type ).
        ri = recid( X_dis-card-type ) .
       run ref/dc-typei.w ( input parparentproc
                        ,input 'ИЗМЕНЕНИЕ':U
                       ,input parhost-code
                       ,input parobj-type
                       ,input parobj-code
                       ,input-output ri ).
        RUn openBr in this-procedure .
        reposition br-dctype to recid cur-ri no-error.
        apply "ENTRY" to br-dctype.
        apply "VALUE-CHANGED" to br-dctype.
    end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  define variable cur-ri as recid no-undo.
  define variable glog as logical no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-dc-type_input-deletion-updating':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then return no-apply .
If available X_dis-card-type then do:
    glog = NO.
    MESSAGE
    substitute("Вы действительно хотите удалить тип ДК &1 эмитент &3"
               , X_dis-card-type.TYPE
               , X_dis-card-type.emitent-host-code)
    VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
    IF NOT glog THEN UNDO, RETURN NO-APPLY.
    cur-ri = recid(X_dis-card-type).
    run ref/dctypei3.p ( INPUT NO
                         ,INPUT cur-ri) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    RUn openBr in this-procedure .
    reposition br-dctype to row 1 no-error.
    apply "ENTRY" to br-dctype.
    apply "VALUE-CHANGED" to br-dctype.
end.
END.
ON CHOOSE OF b-disc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT 'dis-card-type':U
                            ,input X_dis-card-type.emitent-host-code
                            ,input X_dis-card-type.type
                            ,input 0
                            ,input '':U
                            ,input 0
                            ,input 0
                            ,input '':U
                            ,input '':U
                            ,input 0
                            ,input-output v-loc-rid-list ) no-error.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-ri-list AS CHARACTER NO-UNDO.
  IF NOT AVAIL X_dis-card-type THEN RETURN NO-APPLY.
  run ref/dcctypes.w ( input parparentproc
                    , input '':U
                    , input ?
                    , input X_dis-card-type.emitent-host-code
                    , input parhost-code
                    , input parobj-type
                    , input parobj-code
                    , input X_dis-card-type.TYPE
                    , input "one":U
                    , input "subject"
                    , output v-ri-list ) no-error .
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
 If available X_dis-card-type then do:
   ri = recid( X_dis-card-type ) .
   run ref/dc-typei.w ( input parparentproc
                      , input 'ПРОСМОТР':U
                      , input parhost-code
                      , input parobj-type
                      , input parobj-code
                      , input-output ri ).
   apply "ENTRY" to br-dctype.
 end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE loc#log as logical no-undo.
if available X_dis-card-type then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid9 as character no-undo .
define variable v-num-entry9 as integer   no-undo .
assign
  v-str-recid9 = trim( string( recid( X_dis-card-type ) , "->>>>>>>>>>>9":U ) )
  v-num-entry9 = lookup( v-str-recid9 , v-rid-list )
.
if v-num-entry9 > 0 then do:
  assign
    entry( v-num-entry9, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid9
  .
end.
  loc#log = br-dctype:refresh() .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dctype:select-next-row ().
      apply "iteration-changed" to br-dctype in frame Dialog-Frame.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame Dialog-Frame.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
end.
apply "entry" to br-dctype in frame Dialog-Frame.
END.
ON CHOOSE OF B-mask IN FRAME Dialog-Frame
DO:
define variable v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAIL X_dis-card-type THEN RETURN NO-APPLY.
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,input "b-add":U
                   ,INPUT "one":U
                   ,INPUT X_dis-card-type.TYPE
                   ,INPUT X_dis-card-type.emitent-host-code
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
IF ERROR-STATUS:error  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
  CASE Rs-algo-profile:
    when 'rule-by-call':U then do:
      IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
      FOR EACH tt0-rule-call-param NO-LOCK:
        DELETE tt0-rule-call-param.
      END.
      FOR EACH buf_rule-call-param NO-LOCK WHERE
              buf_rule-call-param.codex_id = X_rule-by-call.codex_id
          AND buf_rule-call-param.ruleset_id = X_rule-by-call.ruleset_id
          AND buf_rule-call-param.call_id = X_rule-by-call.call_id:
          CREATE tt0-rule-call-param.
          BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
      END.
      run ref/rulercps.w (
                               input parparentproc
                              ,input this-procedure:handle
                              ,input '':U
                              ,input 'ПРОСМОТР':U
                              ,input 'rule-call-param':U
                              ,input 0
                              ,input ?
                              ,input X_rule-by-call.call_id
                              ,input X_rule-by-call.codex_id
                              ,input X_rule-by-call.ruleset_id
                              ,input X_rule-by-call.order_id
                              ,input X_rule-by-call.RULE_id
                              ,INput substitute("Правило &1", X_rule-by-call.RULE_id)
                              ,input-output table tt0-rule-call-param  ) no-error.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    end.
    when 'rp-by-call':U then do:
      IF NOT AVAILABLE X_rp-by-call THEN RETURN NO-APPLY.
      FOR EACH tt0-rule-call-param NO-LOCK:
        DELETE tt0-rule-call-param.
      END.
      for each buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = X_rp-by-call.call_id
        and buf_rule-by-call.profile_id = X_rp-by-call.profile_id
        and buf_rule-by-call.once-more = X_rp-by-call.once-more,
         EACH buf_rule-call-param NO-LOCK WHERE
              buf_rule-call-param.call_id = buf_rule-by-call.call_id
          AND buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          AND buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          AND buf_rule-call-param.order_id = buf_rule-by-call.order_id :
          CREATE tt0-rule-call-param.
          BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
      END.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = X_rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .
      run value(v-param-form) (
                               input parparentproc
                              ,input this-procedure:handle
                              ,input '':U
                              ,input 'ПРОСМОТР':U
                              ,input 'rp-rule-param':U
                              ,input X_rp-by-call.profile_id
                              ,input X_rp-by-call.once-more
                              ,input X_rp-by-call.call_id
                              ,input 0
                              ,input 0
                              ,input ?
                              ,input 0
                              ,INput substitute("Профайл &1 Номер привязки &2 &3"
                                    , X_rp-by-call.profile_id
                                    , X_rp-by-call.once-more
                                    , calldscr(X_rp-by-call.call_id)
                                    )
                              ,input-output table tt0-rule-call-param  ) no-error.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    end.
  end case.
END.
ON CHOOSE OF b-prop-ref IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_dis-card-type  THEN RETURN NO-APPLY.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/proprefs.w ( INPUT parparentproc
                  ,INPUT (if v-cntxt-db-num = 0
                         and lookup("b-add", bttns) > 0
                         then "b-add":U
                         else '':U)
                  ,INPUT "call_id"
                  ,INPUT 0
                  ,input '':U
                  ,INPUT X_dis-card-type.uniq-key-rec
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF b-rule IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                            INPUT rule-display-option
                                           ,INPUT X_rule-by-call.codex_id
                                           ,INPUT X_rule-by-call.ruleset_id
                                           ,INPUT X_rule-by-call.call_Id
                                           ,INPUT X_rule-by-call.order_id
                                           ,INPUT X_rule-by-call.rule_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    ASSIGN
    rule-display-option = "".
    RETURN NO-APPLY.
  END.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF b-ruleproc IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
IF rule-proc-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if rule-proc-option = "":U then do:
      return no-apply.
end.
run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) no-error .
IF ERROR-STATUS:ERROR THEN DO:
    rule-proc-option = '':U.
    RETURN NO-APPLY.
END.
rule-proc-option = '':U.
END.
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe X_rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = X_rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = X_rule-by-call.ruleset_id.
  run rul/ruleset-i.w ( input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  if available X_dis-card-type then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
     then  v-rid-list = string( recid( X_dis-card-type ) ) .
  end.
END.
ON VALUE-CHANGED OF BR-dctype IN FRAME Dialog-Frame
DO:
  RUN proc-value-changed IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = X_rp-by-call.ps.
  END.
END.
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = X_rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", X_rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + chr(10) + buf_rule.documentation.
  END.
END.
ON CHOOSE OF MENU-ITEM m_graph
DO:
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                              ,INPUT X_rule-by-call.codex_id
                                              ,INPUT X_rule-by-call.ruleset_id
                                              ,INPUT X_rule-by-call.call_Id
                                              ,INPUT X_rule-by-call.order_id
                                              ,INPUT X_rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF MENU-ITEM m_rpoc_graph
DO:
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "graph".
  run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-proc-option = '':U.
      RETURN NO-APPLY.
  END.
  rule-proc-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_rpoc_text
DO:
   IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "text".
  run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-proc-option = '':U.
      RETURN NO-APPLY.
  END.
  rule-proc-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_text
DO:
IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT X_rule-by-call.codex_id
                                            ,INPUT X_rule-by-call.ruleset_id
                                            ,INPUT X_rule-by-call.call_Id
                                            ,INPUT X_rule-by-call.order_id
                                            ,INPUT X_rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON VALUE-CHANGED OF Rs-algo-profile IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-profile.
  CASE rs-algo-profile:
    WHEN 'rule-by-call':U THEN DO:
      HIDE
      br-profile
      IN FRAME Dialog-Frame.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      WITH FRAME Dialog-Frame.
    END.
    WHEN 'rp-by-call':U THEN DO:
        HIDE
        br-rule-by-call
        rs-algo-types
        b-rule
        b-ruleset
        IN FRAME Dialog-Frame.
        DISPLAY
        br-profile
        WITH FRAME Dialog-Frame.
    END.
  END CASE.
END.
ON VALUE-CHANGED OF rs-algo-types IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-types.
  OPEN QUERY br-rule-by-call FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION.
  APPLY "VALUE-CHANGED" TO br-rule-by-call IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-dctype :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   RUN proc-refresh IN THIS-PROCEDURE.
    apply "VALUE-CHANGED" to BR-dctype.
end.
procedure rcpscont_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
define buffer buf_tt0-rule-by-call for ub.rule-by-call.
find first buf_tt0-rule-by-call where
         buf_tt0-rule-by-call.codex_id = p-codex-id
     and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
     and buf_tt0-rule-by-call.profile_id = p-profile-id
     and buf_tt0-rule-by-call.once-more = p-once-more
     and buf_tt0-rule-by-call.rule_id = p-rule-id
     no-error .
if available buf_tt0-rule-by-call then do:
   p-on-off = buf_tt0-rule-by-call.can-calc.
end.
end procedure.
procedure rcpscont_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
define variable v-h as handle no-undo .
define buffer buf_tt0-rule-by-call for ub.rule-by-call.
v-h = buffer ub.rule-by-call:handle.
if v-h:table <> ''
and v-h:table <> ? then do:
  find first buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.codex_id = p-codex-id
      and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
      and buf_tt0-rule-by-call.profile_id = p-profile-id
      and buf_tt0-rule-by-call.once-more = p-once-more
      and buf_tt0-rule-by-call.rule_id = p-rule-id   no-error .
  if not available buf_tt0-rule-by-call then do:
    undo, return error .
  end.
  buf_tt0-rule-by-call.can-calc = p-on-off .
  release buf_tt0-rule-by-call.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-dc'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-is-dc
  ,output v-conf-type
  ) NO-ERROR .
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> 'L':U THEN
    v-is-dc = "no".
  if logical(v-is-dc) = no then do:
    message
    "В Вашей системе недоступна функциональность работы с дисконтными картами"
    view-as alert-box WARNING.
    undo main-block, return error .
  end.
  v-rid-list = p-rid-list.
  RUN Myenable in this-procedure .
  Run OpenBR in this-procedure .
  if v-rid-list <> '':U then do:
    reposition br-dctype to recid( integer(entry(1, v-rid-list))) no-error .
  end.
  HIDE mark-num in frame Dialog-Frame .
  APPLY "ENTRY" TO br-dctype.
  APPLY "VALUE-CHANGED" TO br-dctype.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-algo-profile rs-algo-types E-rule-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-add B-lookup B-chg B-del b-prop-ref b-disc
         B-hist B-Help B-mask b-ruleproc BR-dctype Rs-algo-profile
         rs-algo-types b-rule b-params B-ruleset br-rule-by-call br-profile
         E-rule-name mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-profile FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = x_dis-card-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.    OPEN QUERY br-rule-by-call FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE get-dis-dct-value :
DEFINE INPUT PARAMETER p-emitent-host-code AS integer no-undo.
DEFINE INPUT PARAMETER p-type AS CHARACTER no-undo.
DEFINE INPUT PARAMETER p-host-code AS integer no-undo.
DEFINE INPUT PARAMETER p-obj-type AS character no-undo.
DEFINE INPUT PARAMETER p-obj-code AS integer no-undo.
DEFINE INPUT PARAMETER p-discnt-role AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-discnt-value AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-dct-rule no-lock where
          buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
      and buf_dis-dct-rule.type = p-TYPE
      and buf_dis-dct-rule.host-code = p-host-code
      and buf_dis-dct-rule.obj-type = p-obj-type
      and buf_dis-dct-rule.obj-code = p-obj-code
      and buf_dis-dct-rule.pos-type = 'bo':U
      and buf_dis-dct-rule.discnt-role = p-discnt-role no-error.
if available buf_dis-dct-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num no-error.
  if available buf_dis-rule then do:
    assign
    p-discnt-value        = (IF p-discnt-role = 'def-categ':U
                             THEN string(buf_dis-rule.dis-kat)
                             ELSE string(buf_dis-rule.discnt-value, "->9.99%")).
    .
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME Dialog-Frame:
    clh = BROWSE br-profile:get-browse-column(ii).
    IF clh:LABEL BEGINS "Название" THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
      .
    END.
END.
ASSIGN
rs-algo-profile:RADIO-BUTTONS = "Алгоритмы" + chr(44) +
                                 'rp-by-call':U + chr(44) +
                                "Правила" + chr(44) + 'rule-by-call':U.
rs-algo-profile = 'rp-by-call':U.
ASSIGN
X_rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES
b-rule:menu-mouse in frame Dialog-Frame = 1
b-ruleproc:menu-mouse in frame Dialog-Frame = 1
.
DISPLAY
rs-algo-profile
rs-algo-types
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-sel when lookup("b-sel":U, bttns) > 0
b-mark when lookup("b-mark":U, bttns) > 0
B-add when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
B-chg when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
B-del when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
b-lookup
B-Help
b-mask
b-hist
BR-dctype
br-rule-by-call
br-profile
b-params
b-rule
b-ruleset
b-prop-ref
b-disc
b-ruleproc
rs-algo-types
rs-algo-profile
e-rule-name
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" TO rs-algo-profile.
END PROCEDURE.
PROCEDURE OpenBr :
CASE p-mode:
  when 'все':U then do:
    Open query br-dctype
    for each X_dis-card-type No-LOCK where
            X_dis-card-type.emitent-host-code = 0
        AND X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
 end.
 when 'фирма':U then do:
    Open query br-dctype
    for each X_dis-card-type No-LOCK where
            X_dis-card-type.emitent-host-code = paremitent-code
        and X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
 end.
 otherwise do:
    Open query br-dctype
    for each X_dis-card-type NO-LOCK WHERE
            X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
  end.
END.
END PROCEDURE.
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-DISPLAY-MODE AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
run rul/disprule.p (
                       input p-DISPLAY-MODE
                      ,input p-rule-id
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input p-call-id
                      ,input p-order-id
                       ).
END PROCEDURE.
PROCEDURE proc-refresh :
DEFINE VARIABLE v-doc-rec as RECID NO-UNDO.
if available X_dis-card-type then do:
     v-doc-rec = recid(X_dis-card-type).
END.
RUN Openbr in this-procedure.
REPOSITION br-dctype TO RECID v-doc-rec NO-ERROR.
APPLY 'ENTRY' to br-dctype IN FRAME Dialog-Frame.
APPLY 'VALUE-CHANGED' to br-dctype.
END PROCEDURE.
PROCEDURE proc-value-changed :
OPEN QUERY br-rule-by-call FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION.
OPEN QUERY br-profile FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = x_dis-card-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
IF rs-algo-profile = 'rule-by-call':U THEN DO:
  APPLY "VAlue-changed" TO br-rule-by-call IN FRAME Dialog-Frame.
END.
IF rs-algo-profile = 'rp-by-call':U THEN DO:
  APPLY "VAlue-changed" TO br-profile IN FRAME Dialog-Frame.
END.
END PROCEDURE.
PROCEDURE rule-proc :
DEFINE PARAMETER BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
run rul/run-rule-proc-view.p ( INPUT 'dis-card-type':U
                              ,INPUT buf_dis-card-type.uniq-key-rec
                              ,INPUT 0
                              ,INPUT p-option
                              ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END PROCEDURE.
FUNCTION get-dflt-dct-rule RETURNS CHARACTER
  (
     INPUT p-emitent-host-code AS INTEGER
    ,INPUT p-type AS CHARACTER
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER
    ,INPUT p-discnt-role AS CHARACTER) :
DEFINE variable v-discnt-value AS CHARACTER NO-UNDO .
v-discnt-value = chr(63).
RUN get-dis-dct-value IN THIS-PROCEDURE (
                                             INPUT p-emitent-host-code
                                            ,INPUT p-type
                                            ,INPUT p-host-code
                                            ,INPUT p-obj-type
                                            ,INPUT p-obj-code
                                            ,INPUT p-discnt-role
                                            ,OUTPUT v-discnt-value) NO-ERROR.
RETURN v-discnt-value.
END FUNCTION.
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer) :
define buffer buf_clients for ub.clients.
  if par-emitent-host-code = 0 then return "Глобальная".
  find first buf_clients no-lock where
                 buf_clients.obj-type = 'орг':U and
                  buf_clients.obj-code = par-emitent-host-code no-error.
     if not avail buf_clients then return "?".
     return buf_clients.obj-name.
END FUNCTION.
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, parv-rid-list as character  ) :
if lookup(string(par-rid), parv-rid-list) > 0 then return "*":U.
RETURN "".
END FUNCTION.
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.
RETURN buf_rule-profile.is_dynamic.
END FUNCTION.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN chr(63).
RETURN buf_rule-profile.NAME.
END FUNCTION.
