define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter bttns            as character no-undo .
define input parameter p-title          as character no-undo .
define input parameter p-keep-query     as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка дисконтных карт".
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
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable g#report-num as integer no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
procedure create-dc-list-hist :
define input parameter p-mode as character no-undo .
define input-output parameter p-seq as integer no-undo .
define input parameter p-line as integer no-undo .
define variable p-list-table as character no-undo .
define input parameter p-hist-mode as character no-undo .
define input parameter p-des as character no-undo .
define input parameter p-num-recs as integer no-undo .
define input parameter p-option as character no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-item as character no-undo .
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define variable v-num-add as integer no-undo .
define variable v-num-ignored as integer no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_dc-list-hist where
                   buf_dc-list-hist.id = 0   no-error.
        if not available buf_dc-list-hist then do:
          create buf_dc-list-hist.
          assign
          buf_dc-list-hist.id = 0
          buf_dc-list-hist.line = 0
          buf_dc-list-hist.list-table = '':U
          .
        end.
        assign
        buf_dc-list-hist.des =  p-des
        buf_dc-list-hist.num-recs = p-num-recs
        buf_dc-list-hist.option_  = p-option
        buf_dc-list-hist.item_ = p-item
        .
      end.
      when 'ДОБАВЛЕНИЕ':U then do:
        if p-option begins 'single' then do:
          CASE p-hist-mode:
            when '+':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '-':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '*':U then do:
              assign
              v-num-add = p-num-recs - 1
              p-num-recs = 1
              v-num-ignored  = 0
              .
            end.
          END CASE.
        end.
        create buf_dc-list-hist.
        assign
        buf_dc-list-hist.id = p-seq
        buf_dc-list-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_dc-list-hist.des =  p-des
        buf_dc-list-hist.line = p-line
        buf_dc-list-hist.num-recs = p-num-recs
        buf_dc-list-hist.option_  = p-option
        buf_dc-list-hist.item_ = p-item
        buf_dc-list-hist.hist-mode =  p-hist-mode
        buf_dc-list-hist.status_ =  p-status_
        buf_dc-list-hist.num-add = v-num-add
        buf_dc-list-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_dc-list-hist where
                  buf_dc-list-hist.id = p-seq
              and buf_dc-list-hist.line = p-line no-error .
        if  available buf_dc-list-hist then do:
          assign
          buf_dc-list-hist.des =  p-des
          buf_dc-list-hist.num-recs = p-num-recs
          buf_dc-list-hist.option_  = p-option
          buf_dc-list-hist.item_ = p-item
          buf_dc-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_dc-list-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_dc-list-hist where
                  buf_dc-list-hist.id = p-seq
              and buf_dc-list-hist.line = p-line  no-error .
        if available buf_dc-list-hist then do:
          assign
          buf_dc-list-hist.hist-mode =  p-hist-mode
          buf_dc-list-hist.num-recs  = (if buf_dc-list-hist.line = 0 then p-num-recs else buf_dc-list-hist.num-recs)
          buf_dc-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_dc-list-hist.list-table)
          .
        end.
      end.
    END CASE.
    if p-tbl-name <> "":U
    and valid-handle(p-bh_tbl-name)
    then do:
      run gen-key-rec  in this-procedure (
                                            input  p-tbl-name
                                           ,input  p-bh_tbl-name
                                           ,output p-item) no-error .
      if not error-status:error then do:
        assign
        buf_dc-list-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_dc-list-hist.item_ = "!ERROR"
        .
      end.
    end.
  end.
end procedure.
FUNCTION get-line-mode returns character(input p-hist-mode as character):
case p-hist-mode:
  when '+':U then
    return  'ДОБАВЛЕНИЕ':U.
  when '-':U then
    return  'удаление':U.
  when '*':U then
    return  'ОСТАВИТЬ':U.
end CASE.
END FUNCTION.
FUNCTION get-hist-mode returns character(input p-line-mode as character):
case p-line-mode:
  when 'ДОБАВЛЕНИЕ':U then
    return  "+".
  when 'удаление':U then
    return  "-".
  when 'ОСТАВИТЬ':U then
    return  "*".
end CASE.
END FUNCTION.
procedure proc-write-filter-expression :
define input parameter p-filter-expression as character no-undo .
define variable v-ii as integer no-undo .
output to value(string(g#report-num) + ".whr").
put .
if num-entries(p-filter-expression) > 0 then do:
   put unformatted 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     put unformatted entry(v-ii, p-filter-expression) skip.
   end.
   put unformatted ')'.
end.
output close.
end procedure.
procedure proc-write-filter-expression-var :
define input parameter p-filter-expression as character no-undo .
define output parameter p-string as character no-undo .
define variable v-ii as integer no-undo .
if num-entries(p-filter-expression) > 0 then do:
   p-string = 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     p-string = p-string + entry(v-ii, p-filter-expression) + chr(10).
   end.
   p-string = p-string + ')'.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-d-pcnt RETURNS CHARACTER
  ( buffer loc-dis-card for dc-list,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-discnt-role:
    when 'def-pcnt':U  then do:
      assign
      v-node-code = 1.
    end.
    when 'def-cash-pcnt':U then do:
      assign
      v-node-code = 2.
    end.
    when 'def-categ':U then do:
      assign
      v-node-code = 3.
    end.
  end.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
    if loc-d-v = ? then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = loc-dis-card.category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer l-dc-list for dc-list.
define variable old-mode as character no-undo .
define variable f-name as char init "default.dc" no-undo.
define variable grp-list as char no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine variable RS-list-method AS CHARACTER.
define variable lns-cnt as integer no-undo .
define variable lns-ignore as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable vtype1 as character no-undo.
define variable vvalue as character no-undo.
define variable vvalue1 as character no-undo.
define variable save-option as character no-undo.
define variable print-option as character no-undo.
define variable obj-d-pcnt like ub.dis-card.d-pcnt no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable cli-name as char no-undo.
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable macro-play-option as character no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .
define stream slog .
define temp-table temp-list no-undo
field fname as character format "X(40)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table macro-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
FUNCTION get-num-chk RETURNS CHARACTER
  ( buffer loc-dis-card for dc-list )  FORWARD.
FUNCTION stat-line RETURNS CHARACTER
  ( input p-status-chr AS character )  FORWARD.
DEFINE MENU MENU-B-print
       MENU-ITEM m_main-print   LABEL "Простой формат"
       MENU-ITEM m_sel-print    LABEL "Выбор   полей" .
DEFINE MENU MENU-B-save
       MENU-ITEM m_dc-save      LABEL "Файл списка дисконтных карт"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m_to-make      LABEL "Файл для изготовления"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка"
       MENU-ITEM m_dc-save-db   LABEL "Хранимый в БД список дисконтных карт"
       MENU-ITEM m-macros-save-db   LABEL "Хранимый в БД макрос формирования списка"
       .
DEFINE MENU m-play
      MENU-ITEM m-macro-file    LABEL "Сохраненный в файле макрос формирования списка карт"
      MENU-ITEM m-macro-lob     LABEL "Сохраненный в БД макрос формирования списка карт"
      .
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 20 BY 1 TOOLTIP "Добавление в список карт 1 строку".
DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".
DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все карты (строки)".
DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 20 BY 1 TOOLTIP "Удаление из списка карт текущую строку".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из списка карт (передача списка другой программе)"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр описания текущей карты".
DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".
DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 20 BY 1 TOOLTIP "Оставить в списке только текущую строку".
DEFINE BUTTON B-save
     LABEL "Со&хранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить список карт в текстовом файле, EXCEL".
DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 75.63 BY 1.54 NO-UNDO.
DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1 TOOLTIP "Строка текущего состояния списка"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE NameOrCode AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40.13 BY 1 NO-UNDO.
DEFINE VARIABLE n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Карта", "1",
"Клиент", "2"
     SIZE 23 BY .79 NO-UNDO.
DEFINE VARIABLE RS-Status AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 48 BY .75 NO-UNDO.
DEFINE QUERY BR-list FOR
      dc-list SCROLLING.
DEFINE QUERY br-option FOR
      temp-list SCROLLING.
DEFINE BROWSE BR-list
  QUERY BR-list NO-LOCK DISPLAY
      dc-list.d-card COLUMN-LABEL "Номер" FORMAT "X(19)":U
      dc-list.issue-code COLUMN-LABEL "Маг-н" FORMAT "99999":U
      dc-list.issue-date COLUMN-LABEL "Выдано" FORMAT "99/99/9999":U
      get-d-pcnt(buffer dc-list, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input 'def-pcnt':U, output obj-d-pcnt) COLUMN-LABEL "Скидка" FORMAT "X(12)":U
      dc-list.status_ FORMAT "X(4)":U
      dc-list.emitent-host-code COLUMN-LABEL "Фирма" FORMAT "99999":U
      dc-list.sourced-card COLUMN-LABEL "К карте" FORMAT "X(16)":U
      obj-d-pcnt COLUMN-LABEL "Скидка на!объекте" FORMAT "->9.99%":U
      dc-list.valid-date COLUMN-LABEL "Действ.по" FORMAT "99/99/9999":U
      dc-list.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
      dc-list.credit-card FORMAT "+/":U
      dc-list.lim-kr FORMAT ">>>,>>>,>>>,>>9.99":U
      (cli-name) COLUMN-LABEL "Название/ФИО" FORMAT "x(29)":U
      (dc-list.cli-type + STRING (dc-list.cli-code)) COLUMN-LABEL "Клиент" FORMAT "X(10)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76.5 BY 15.13.
DEFINE BROWSE BR-option
  QUERY BR-option DISPLAY
      temp-list.fname format "X(40)"
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 30 BY 21.
DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     BR-option AT ROW 2 COL 79
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-print AT ROW 2 COL 21
     B-hist AT ROW 2 COL 31
     B-lkp AT ROW 2 COL 41
     B-clr AT ROW 2 COL 51
     B-Help AT ROW 1 COL 61
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 31
     B-rest AT ROW 3 COL 51
     B-macro AT ROW 3 COL 71
     B-stop AT ROW 3 COL 75
     B-clear-macro AT ROW 3 COL 75
     B-record AT ROW 3 COL 75
     NameOrCode AT ROW 4.04 COL 34 COLON-ALIGNED NO-LABEL
     n-c AT ROW 4.08 COL 2.38 NO-LABEL
     RS-Status AT ROW 4.96 COL 3.25 NO-LABEL
     BR-list AT ROW 5.96 COL 1.13
     ed-notes AT ROW 21.38 COL 1 NO-LABEL
     f-tot-lns AT ROW 5 COL 66 COLON-ALIGNED NO-LABEL
     SPACE(22.00) SKIP(17.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список дисконтных карт"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ASSIGN
       B-macro:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-play:HANDLE.
ASSIGN
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.
ASSIGN
       ed-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
on GO of frame Dialog-Frame do:
  define variable glog as logical no-undo .
  if lookup('list':U, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый список ДК?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m_dc-save-db-proc in this-procedure no-error.
    end.
  end.
  if lookup('list-macro':U, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый макрос формирования списка ДК?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m-macros-save-db-proc in this-procedure no-error .
    end.
  end.
end.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-clr IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define buffer buf-dc-list-hist for dc-list-hist.
glog = no.
message
"Удаление всех строк списка. Вы уверены ?"
 view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each dc-list:
  delete dc-list.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-dc-list-hist:
  delete buf-dc-list-hist.
end.
run create-dc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список карт очищен."
                                     , input 0
                                     , input "clear"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
ed-notes:screen-value = ''.
display
tot-lns @ f-tot-lns
with frame Dialog-Frame.
run MyEnable in this-procedure .
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define buffer buf_dc-list-hist for dc-list-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
find first buf_dc-list-hist no-lock where buf_dc-list-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка карт "
(if available buf_dc-list-hist
then buf_dc-list-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") chr(32)
string("Действие", "X(9)") chr(32)
string("записей", "X(9)") chr(32)
string(" = итого", "X(12)") chr(32)
string("Множество", "X(155)")
skip(0)
fill('-':U, 9) chr(32)
fill('-':U, 9) chr(32)
fill('-':U, 9) chr(32)
fill('-':U, 12) chr(32)
fill('-':U, 155)
skip(0)
.
for each buf_dc-list-hist where buf_dc-list-hist.id > 0
by buf_dc-list-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_dc-list-hist.line = 0
   then string(buf_dc-list-hist.id, ">>>>>>>>9")
   else fill(chr(32) , 9)
  )  chr(32)
  (if buf_dc-list-hist.item_ <> '':U
   then string(buf_dc-list-hist.hist-mode, "X(8)")
   else fill( chr(32), 8)) chr(32)
  string(buf_dc-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
  string(buf_dc-list-hist.num-recs, ">>>>>>>>9")  chr(32)
  string(buf_dc-list-hist.des, "X(155)") skip.
end.
output stream prnlibstream close.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as recid no-undo .
  if not available dc-list then do:
  message "Неправильно выбрана карта."
          view-as alert-box error.
  return no-apply.
end.
FIND FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.d-card = dc-list.d-card no-error .
if error-status:error then  return no-apply.
v-ref-rec = recid( ub.dis-card ) .
run ref/dcardi.w (
               input parparentproc
              ,input 'ПРОСМОТР':U
              ,input ub.dis-card.emitent-host-code
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input ?
              ,input-output v-ref-rec ) .
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-frame-width as integer no-undo.
if print-option = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
end.
run str/dcl-prn.p (
               input parparentproc
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input print-option
              ,output v-Frame-Width) no-error.
print-option = "".
if v-frame-width <= 198 then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input ( if v-frame-width <= 136
                                                    then 0
                                                    else 8)
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input ( if v-frame-width <= 255
                                                    then 1
                                                    else 20)
                                            ).
end.
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
  if save-option = "" then do:
      run gbl/pop-up.p (self:handle, no) no-error.
  end.
  run proc-b-save  in this-procedure (save-option) no-error.
  save-option = '':U.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF BR-list IN FRAME Dialog-Frame
DO:
    display tot-lns @ f-tot-lns with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF br-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_dc-save
DO:
  assign
  save-option = "dc-list":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_dc-save-db
DO:
  assign
  save-option = "dc-list-db":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-macros-save  DO:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
run proc-macros in this-procedure no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-macros-save-db  DO:
  assign
  save-option = "dc-list-macros-db":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_main-print
DO:
  assign
  print-option = "main":U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_sel-print
DO:
  assign
  print-option = "extended":U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-title-save
DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА КАРТ" + '\':u
    + 'format=' + "X(60)" + '\':u
    + 'type=' + 'C':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=60\':u
    + 'fillin_height=1\':u
    + 'max-chars=60\':u
    + 'readonly=no\':u
    , input-output v-value
    ).
if return-value = 'false':u then return NO-apply.
run create-dc-list-hist in this-procedure (input 'title'
                                     , input-output v-seq
                                     , input 0
                                     , input 'N':U
                                     , input v-value
                                     , input tot-lns
                                     , input "title"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
assign
frame Dialog-Frame:title = substitute("СПИСОК  КАРТ &1", v-value).
END.
ON CHOOSE OF MENU-ITEM m_to-make
DO:
  assign
  save-option = "to-make":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_xls-save
DO:
  assign
  save-option = "excel":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF n-c IN FRAME Dialog-Frame
DO:
    define variable loc#log as logical no-undo.
    if can-do( 'карта':U, n-c ) then do:
        assign
            NameOrCode:width-chars = 16
            NameOrCode:format = "x(16)" .
    end.
    else do:
        assign
            NameOrCode:width-chars = 9
            NameOrCode:format = "X(9)" .
    end.
    if nameorcode:visible in frame Dialog-Frame then
    apply "entry" to NameOrCode in frame Dialog-Frame .
END.
ON CTRL-J OF NameOrCode IN FRAME Dialog-Frame
DO:
  assign
  n-c
  nameorcode.
  run proc-find-nameorcode in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF NameOrCode IN FRAME Dialog-Frame
DO:
  assign
  n-c
  nameorcode.
  run proc-find-nameorcode  in this-procedure  no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF RS-Status IN FRAME Dialog-Frame
DO:
  assign
  RS-status.
END.
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dialog-Frame DO:
    apply "choose" to b-lkp in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-list :handle
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
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-option :handle
  ) .
run diasize_init in this-procedure .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-list :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-dc :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
if rs-list-method = "single":U or
  (ub.dis-card.status_ = 'тек':U and (rs-status = 'тек':U or rs-status = 'все':U)) or
  (ub.dis-card.status_ = 'удал':U and (rs-status = 'удал':U or rs-status = 'все':U)) or
  (ub.dis-card.status_ = 'блок':U and (rs-status = 'блок':U or rs-status = 'все':U))
  then do:
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    find first dc-list where
               dc-list.d-card = ub.dis-card.d-card no-error.
    if available dc-list then do:
      if line-mode = 'удаление':U then do:
        lns-cnt = lns-cnt + 1.
        delete dc-list.
      end.
      else do:
        if dc-list.to-del = ? then.
        else do:
          lns-cnt = lns-cnt + 1.
          dc-list.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find dc-list
  where dc-list.d-card = dis-card.d-card
  no-error .
if available dc-list then do:
  assign
    dc-list.to-del = no
  .
end.
else do:
  create dc-list .
  buffer-copy dis-card to dc-list
  assign
    dc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (dc-list)
  .
end.
    end.
  if lns-cnt modulo 25 = 0 then
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame Dialog-Frame.
end.
end.
def var vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-no-context as logical no-undo .
define variable v-user-obj-type as character no-undo .
define variable v-user-obj-code as integer no-undo .
FUNCTION prepare-rowid returns character ( input p-uniq-key-rec as character
                                         , input p-no-context as logical ):
define variable v-uniq-key-rec as character no-undo .
if p-no-context and p-uniq-key-rec begins 'user-obj':U then do:
  v-uniq-key-rec = 'clients':U + chr(3) +
                  entry(4, p-uniq-key-rec, chr(3)) + chr(3) +
                  entry(5, p-uniq-key-rec, chr(3)).
end.
else do:
  v-uniq-key-rec = p-uniq-key-rec.
  case entry(1, p-uniq-key-rec, chr(3)):
     when 'user-obj':U then do:
       entry(lookup("user-id", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, chr(3)) = v-cntxt-userid.
       entry(lookup("db-num", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, chr(3)) = string(v-cntxt-db-num).
     end.
  end case.
end.
return v-uniq-key-rec.
end function.
procedure find-user-obj-rowid :
define input parameter p-rowid as rowid no-undo .
define input parameter p-no-context as logical no-undo .
define output parameter p-user-obj-type as character no-undo .
define output parameter p-user-obj-code as integer no-undo .
define buffer user-obj_clients for ub.clients.
define buffer user-obj_user-obj for ub.user-obj .
if p-no-context then do:
  find first user-obj_clients no-lock where rowid(user-obj_clients) = p-rowid.
  assign
  p-user-obj-type = user-obj_clients.obj-type
  p-user-obj-code = user-obj_clients.obj-code.
end.
else do:
  find first user-obj_user-obj no-lock where rowid(user-obj_user-obj) = p-rowid no-error.
  if not available user-obj_user-obj then do:
    undo, return error substitute("Не удалось выполнить в данной БД записанные действия пользователя").
  end.
  assign
  p-user-obj-type = user-obj_user-obj.obj-type
  p-user-obj-code = user-obj_user-obj.obj-code.
end.
end procedure.
define variable an-listp-start-macro-id as integer no-undo init ?.
define variable an-listp-end-macro-id as integer no-undo  init ?.
define variable an-listp-macros-label-id as integer   no-undo .
define variable v-macro-is-running as logical no-undo .
define variable v-current-step as integer no-undo .
define variable v-expand as logical no-undo .
define variable v-downed as character no-undo .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define     temp-table keep-macro-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
procedure assign-nums :
define input-output parameter p-num-add as integer no-undo .
define input-output parameter p-num-rec as integer no-undo .
define input-output parameter p-num-ignored as integer no-undo .
define input parameter p-line-mode as character no-undo .
assign
p-num-add  = lns-cnt - v-num-add
p-num-rec = (if line-mode = 'ОСТАВИТЬ':U
                          then (tot-lns + p-num-add)
                          else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))
tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)
p-num-ignored = lns-ignore  - v-num-ignored
v-num-add             = lns-cnt
v-num-ignored         = lns-ignore
.
END PROCEDURE.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
or INSERT-MODE of br-list
DO:
define variable glog as logical no-undo .
define buffer buf-dc-list-hist for dc-list-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each dc-list:
      delete dc-list.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-dc-list-hist:
      delete buf-dc-list-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-dc-list-hist in this-procedure (
                                          input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '0':U
                                        , input "# Реинициализация списка."
                                        , input 0
                                        , input "init"
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
    display
    tot-lns @ f-tot-lns
    with frame Dialog-Frame.
    run MyEnable in this-procedure .
 end.
 else do:
   assign rs-list-method = "single".
   run proc-b-add in this-procedure(input no
                                  ,input ?
                                  ,input rs-list-method
                                  ,input rs-status)  no-error .
  if error-status:error then return no-apply.
end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
or DELETE-CHARACTER of br-list
DO:
  if not available dc-list then return no-apply.
  assign rs-list-method = "single".
    run proc-b-del in this-procedure(
                                               input no
                                              ,input ?
                                              ,input rs-list-method
                                              ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-rest IN FRAME Dialog-Frame
DO:
if not available dc-list then return no-apply.
  assign rs-list-method = "single".
 run proc-b-rest in this-procedure(
                                                input no
                                               ,input ?
                                               ,input rs-list-method
                                               ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
on choose of MENU-ITEM m-macro-file in menu m-play DO:
  assign
  macro-play-option = 'file':U.
  APPLY "CHOOSE" to b-macro in frame Dialog-Frame.
end.
on choose of MENU-ITEM m-macro-lob in menu m-play DO:
  assign
  macro-play-option = 'lob':U.
  APPLY "CHOOSE" to b-macro in frame Dialog-Frame.
end.
ON CHOOSE OF B-macro IN FRAME Dialog-Frame
DO:
if macro-play-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if macro-play-option = '':U then return no-apply.
run proc-b-macro in this-procedure ( input macro-play-option) no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-record IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
message
"Начать запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-start-macro-id = v-seq
an-listp-end-macro-id = ?
.
  menu-item m-macro-file:label in menu m-play = "Ранее записанный макрос формирования списка товаров".
  menu-item m-macro-lob:sensitive in menu m-play = no.
disable
b-record with frame Dialog-Frame .
hide
b-record
b-macro
in frame Dialog-Frame .
enable
b-stop with frame Dialog-Frame .
run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input 'o':U
                                    , input "Начата запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
END.
ON CHOOSE OF B-stop IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
message
"Закончить запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-end-macro-id = v-seq.
disable
b-stop with frame Dialog-Frame .
hide
b-stop in frame Dialog-Frame .
enable
b-record
b-macro
with frame Dialog-Frame .
run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '[]':U
                                    , input "Закончена запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
for each macro-list-hist:
  delete macro-list-hist.
end.
for each buf_dc-list-hist where
        buf_dc-list-hist.id >=  an-listp-start-macro-id
  and  buf_dc-list-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_dc-list-hist
  except id num-recs num-add num-ignored
  to macro-list-hist
  assign
  macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  .
end.
END.
ON CHOOSE OF b-clear-macro IN FRAME Dialog-Frame
DO:
disable
b-clear-macro with frame Dialog-Frame .
assign
an-listp-start-macro-id = ?
an-listp-end-macro-id = ?
an-listp-macros-label-id = 0
.
menu-item m-macro-lob:sensitive in menu m-play = yes.
for each macro-list-hist:
  delete macro-list-hist.
end.
hide
b-clear-macro in frame Dialog-Frame .
enable
b-record
b-macro
with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF br-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.
PROCEDURE get-operation :
define input parameter p-message as character no-undo .
define output parameter p-operation as integer no-undo .
  do
  on error undo, return error
  :
    run gbl/d-askw.w (
                  input "Выбор операции над заданным списком"
                 ,input (p-message + chr(10) +
                         "Выберите операцию, которую Вы хотите применить к полученному списку" +  chr(10) )
                 ,input "|"
                ,input  ("Добавить" + (if p-keep-query then "^disable" else '':U) + "|" +
                         "Удалить" + "|" +
                         "Оставить" + "|" +
                         "Отказ")
                 ,input ("Добавить полученный список к уже имеющемуся" + "|" +
                        "Удалить полученный список из уже имеющегося" + "|" +
                        "Оставить в уже имеющемся списке только элементы полученного списка" +  "|" +
                        "Ничего не делать")
                 ,input  (if p-keep-query then 2 else 1)
                 ,input  4
                 ,output p-operation).
   if p-operation = 4 then do:
      return error .
   end.
  end.
END PROCEDURE.
PROCEDURE proc-fill-temp-list :
  define variable v-index               as integer   no-undo .
  define variable v-num-entries-options as integer   no-undo .
  do
  on error undo, return error
  :
    assign
      v-num-entries-options = num-entries("Текущая строка,single,                               Карта,card,                                           Клиент,cli,                                           Группа клиентов,cli-grp,                              Глобальные карты,global,                              Карты фирмы,company,                                  Карты определенного типа,type,                        Все физ.&лица,person,                                 Контрагенты по док-там,waybill,                       С установл. &атр. кл-та,attr,                         С атрибутом кл-та= ,attr-val,                         Значения общих итогов,general-sum-id,                 Значения частных итогов,partial-sum-id,               Дата посл.изм.общих итогов,last-change-general-sum-id,Дата посл.изм.частных итогов,last-change-partial-sum-id,Карты со свойством,dcp,                               Карты стоплиста,stop-list,                            Удаленные,deleted,                                    Карты по продаже,inkas,                               Карты по чеку,chk-doc,                                Карты кл-тов из списка,cli-list,                      Карты док-тов из списка,doc-list,                     Карты чеков из списка,chk-list,                       Файл,file,                                            Хранимый в БД список,clob-data,                         Фильтр,filter,                                        Все карты, all")
    .
    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,"Текущая строка,single,                               Карта,card,                                           Клиент,cli,                                           Группа клиентов,cli-grp,                              Глобальные карты,global,                              Карты фирмы,company,                                  Карты определенного типа,type,                        Все физ.&лица,person,                                 Контрагенты по док-там,waybill,                       С установл. &атр. кл-та,attr,                         С атрибутом кл-та= ,attr-val,                         Значения общих итогов,general-sum-id,                 Значения частных итогов,partial-sum-id,               Дата посл.изм.общих итогов,last-change-general-sum-id,Дата посл.изм.частных итогов,last-change-partial-sum-id,Карты со свойством,dcp,                               Карты стоплиста,stop-list,                            Удаленные,deleted,                                    Карты по продаже,inkas,                               Карты по чеку,chk-doc,                                Карты кл-тов из списка,cli-list,                      Карты док-тов из списка,doc-list,                     Карты чеков из списка,chk-list,                       Файл,file,                                            Хранимый в БД список,clob-data,                         Фильтр,filter,                                        Все карты, all"
                                     )
                               ,chr(32)
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,"Текущая строка,single,                               Карта,card,                                           Клиент,cli,                                           Группа клиентов,cli-grp,                              Глобальные карты,global,                              Карты фирмы,company,                                  Карты определенного типа,type,                        Все физ.&лица,person,                                 Контрагенты по док-там,waybill,                       С установл. &атр. кл-та,attr,                         С атрибутом кл-та= ,attr-val,                         Значения общих итогов,general-sum-id,                 Значения частных итогов,partial-sum-id,               Дата посл.изм.общих итогов,last-change-general-sum-id,Дата посл.изм.частных итогов,last-change-partial-sum-id,Карты со свойством,dcp,                               Карты стоплиста,stop-list,                            Удаленные,deleted,                                    Карты по продаже,inkas,                               Карты по чеку,chk-doc,                                Карты кл-тов из списка,cli-list,                      Карты док-тов из списка,doc-list,                     Карты чеков из списка,chk-list,                       Файл,file,                                            Хранимый в БД список,clob-data,                         Фильтр,filter,                                        Все карты, all"
                                     )
                               ,chr(32)
                               )
        temp-list.id     = v-index
      .
    end.
  end.
END PROCEDURE.
procedure proc-b-macro :
define input parameter p-option as character no-undo .
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define variable v-result as character no-undo .
define variable v-des as character no-undo .
define variable v-hist-mode as character no-undo .
define variable v-file as logical no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
do
on error undo, return error
:
  if v-macro-is-running then do:
  end.
  else do:
    glog = yes.
    if an-listp-start-macro-id >= 1 then do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из записанного макроса"
      view-as alert-box question buttons OK-Cancel update glog.
        end.
        when "lob" then do:
          message
          "Нелья!"
          view-as alert-box question buttons OK-Cancel update glog.
          run MyEnable in this-procedure .
          return error.
        end.
      end case.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      if an-listp-end-macro-id = ? then do:
        assign
        an-listp-end-macro-id  = v-seq.
        for each macro-list-hist:
          delete macro-list-hist.
        end.
        for each buf_dc-list-hist where
                buf_dc-list-hist.id >=  an-listp-start-macro-id
          and  buf_dc-list-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_dc-list-hist
          except id num-recs num-add num-ignored
          to macro-list-hist
          assign
          macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          macro-list-hist.done = no
          .
        end.
      end.
      else do:
        find last macro-list-hist no-error.
        if available macro-list-hist then do:
          v-id = macro-list-hist.id.
        end.
      end.
    end.
    else do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из ранее сохраненного в файле макроса"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Макрос формирования списка *.dcm" "*.dcm"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "dcm".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
        end.
        when "lob" then do:
          message
          "Согласно командам формирования списка из макроса, сохраненного в БД"
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run MyEnable in this-procedure .
            return error.
          end.
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-sel'
                              ,input "uniq-key-rec"
                              ,input ""
                              ,input 'list-macro':U
                              ,input 'dc-list'
                              ,input -1
                              ,input-output v-rid-list) no-error.
          if v-rid-list = '' then do:
            run MyEnable in this-procedure.
            return error.
          end.
          find first buf_clob-bind no-lock where
                    recid(buf_clob-bind) = integer(v-rid-list) no-error.
          if not available buf_clob-bind then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run MyEnable in this-procedure .
            return error.
          end.
          find first buf_clob-data no-lock where
                    buf_clob-data.db-num = buf_clob-bind.db-num
                and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
          if not available buf_clob-data then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run MyEnable in this-procedure .
            return error.
          end.
          if buf_clob-data.db-num <> v-cntxt-db-num then do:
            message
            substitute("Возможно, не все действия пользователя БД &1 удастся воспроизвести!&2Продолжить?"
                      , buf_clob-data.db-num
                      , chr(10))
           view-as alert-box question buttons yes-no update v-ok.
           if not v-ok then do:
              run MyEnable in this-procedure .
              return error.
           end.
          end.
          run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name) .
          copy-lob from object buf_clob-data.cdata
          to file f-name.
          run gbl/filename.p
            (input  v-file-name
            ,output f-name
            ,output v-path
            ,output v-file-name
            ,output v-file-name-no-ext
            ,output v-file-name-ext
            ) no-error .
          if error-status:error then do:
          end.
        end.
      end case.
      for each macro-list-hist:
        delete macro-list-hist.
      end.
      input stream sout from value (f-name).
      _macro:
      repeat:
        create macro-list-hist.
        import stream sout macro-list-hist no-error.
        if error-status:error then do:
            undo _macro, next _macro.
        end.
        assign
        macro-list-hist.num-rec = 0
        macro-list-hist.num-add = 0
        macro-list-hist.num-ignored = 0
        v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
        macro-list-hist.done = no
        .
      end.
      find first macro-list-hist where
              macro-list-hist.id = 0.
      delete macro-list-hist.
      input stream sout close.
      If p-option = "lob" then do:
       os-delete value(f-name).
      end.
      v-file = yes.
    end.
    an-listp-macros-label-id = v-seq.
    run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '>':U
                                        , input (if v-file
                                                then substitute("Файл макроса : &1", f-name)
                                                else substitute("Записанный макрос")
                                                )
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U
                                        , input (if v-file then f-name else '':U)
                                        , input '':U
                                        , input ?
                                        ).
  end.
  disable
  b-record
  b-macro
  with frame Dialog-Frame .
  hide
  b-record in frame Dialog-Frame .
  enable
  b-clear-macro with frame Dialog-Frame .
  v-macro-is-running = yes.
  run str/listmcro.w (input parparentproc
                ,input this-procedure:handle
               ,input "Макрос формирования списка карт" + chr(4) + "dcm"
                ,input "b-play,b-step"
                ,input-output v-current-step
                ,input v-id
                ,output v-result) no-error .
  if error-status:error
  or v-result = "b-stop"
  or v-result = 'end':U
  then do:
    for each macro-list-hist:
      delete macro-list-hist.
    end.
    assign
    an-listp-start-macro-id = ?
    an-listp-end-macro-id = ?
    an-listp-macros-label-id = 0
    .
    menu-item m-macro-file:label in menu m-play = "Сохраненный в файле макрос формирования списка товаров".
    menu-item m-macro-lob:sensitive in menu m-play = yes.
    if v-result = 'b-stop' then do:
      assign
      v-hist-mode = '[]':U
      v-des = "Выполнение макроса прекращено пользователем"
      .
      hide
      b-clear-macro
      b-stop
      in frame Dialog-Frame .
      enable
      b-record
      with frame Dialog-Frame .
    end.
    if v-result = 'end' then do:
      assign
      v-hist-mode = '<':U
      v-des = "Выполнение макроса завершено"
      .
      hide
      b-clear-macro
      b-stop
      in frame Dialog-Frame .
      enable
      b-record
      with frame Dialog-Frame .
    end.
    if error-status:error then do:
      assign
      v-hist-mode = 'E':U
      v-des = "Выполнение макроса прекращено из-за ошибки"
      .
    end.
    run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input v-hist-mode
                                        , input v-des
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U
                                        , input f-name
                                        , input '':U
                                        , input ?
                                        ) no-error .
    assign
    v-macro-is-running = no
    v-current-step = 0
    .
  end.
  enable
  b-macro
  with frame Dialog-Frame .
end.
end procedure.
procedure proc-create-macro-list-hist :
define input parameter p-list-table as character no-undo .
define input parameter p-id as integer           no-undo .
define input parameter p-line as integer         no-undo .
define input parameter p-hist-mode as character  no-undo .
define input parameter p-des as character        no-undo .
define input parameter p-option_ as character    no-undo .
define input parameter p-item_ as character      no-undo .
define input parameter p-status_ as character    no-undo .
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
  do
  on error undo, return error return-value
  :
    create buf_macro-list-hist.
    assign
    buf_macro-list-hist.list-table = p-list-table
    buf_macro-list-hist.id         = p-id
    buf_macro-list-hist.line       = p-line
    buf_macro-list-hist.hist-mode  = p-hist-mode
    buf_macro-list-hist.des        = p-des
    buf_macro-list-hist.option_    = p-option_
    buf_macro-list-hist.item_      = p-item_
    buf_macro-list-hist.status_    = p-status_
    .
    if p-keep-query then do:
      create buf_keep-macro-list-hist.
      buffer-copy buf_macro-list-hist to buf_keep-macro-list-hist.
    end.
  end.
end procedure.
procedure proc-macro-play :
define input parameter p-id as integer no-undo .
define input parameter p-step as logical no-undo .
define input parameter p-max-id as integer no-undo .
define variable v-id as integer no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-old-seq as integer no-undo .
define variable v-current-id as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-rs-do-error as logical no-undo .
define  buffer buf_macro-list-hist for macro-list-hist.
define  buffer buf_dc-list-hist for dc-list-hist.
do
on error undo, return error return-value
:
  for each macro-list-hist where (p-id = 0 or macro-list-hist.id = p-id):
    assign
    v-current-id = v-current-id + 1
    v-id = macro-list-hist.id.
    CASE entry(1, macro-list-hist.option_, chr(4)):
      when 'macro':U
      or
      when 'title':U
      or
      when 'start':U
      then do:
      end.
      when 'clear':U then do:
        for each dc-list:
          delete dc-list.
        end.
        for each dc-list-hist where dc-list-hist.id > an-listp-macros-label-id:
          delete dc-list-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_dc-list-hist.
        buffer-copy macro-list-hist
        to buf_dc-list-hist
        assign buf_dc-list-hist.id = v-seq
        v-temp-seq = v-seq
        v-seq = v-seq + 1
        v-no-hist = v-no-hist + 1
        .
        run MyEnable in this-procedure .
      end.
      when 'single' then do:
         run gen-row-keyr  in this-procedure (  input  macro-list-hist.item_
                                              ,input ?
                                              ,input 'ub'
                                              ,input ?
                                              ,input no-lock
                                              ,output v-rowid
                                              ,output v-tbl-name) no-error .
        if not error-status:error then do:
          CASE macro-list-hist.hist-mode:
            when '+':U then do:
              run proc-b-add in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '-':U then do:
              run proc-b-del in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '*':U then do:
              run proc-b-rest in this-procedure(input yes
                                               ,input v-rowid
                                               ,input macro-list-hist.option_
                                               ,input macro-list-hist.status_) no-error .
            end.
          END.
          if error-status:error then do:
              return ("error" + chr(4) + return-value) .
          end.
          find first  buf_dc-list-hist where
                  buf_dc-list-hist.id = v-seq - 1 no-error .
          if available buf_dc-list-hist then
          assign
          macro-list-hist.num-recs = buf_dc-list-hist.num-recs
          macro-list-hist.num-add = buf_dc-list-hist.num-add
          macro-list-hist.num-ignored = buf_dc-list-hist.num-ignored
          .
        end.
        else do:
          return ("error" + chr(4) + return-value).
        end.
      end.
      otherwise do:
        if can-find(first temp-list where temp-list.fvalue = macro-list-hist.option_)
        or lookup(macro-list-hist.option_, '':U) > 0
        then do:
          if macro-list-hist.line = 0 then do:
            v-no-hist = 0.
            for each buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id:
              create buf_dc-list-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_dc-list-hist
              assign
              buf_dc-list-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
              v-temp-seq = (if buf_macro-list-hist.line = 0 then v-seq else v-temp-seq )
              v-seq = (if buf_macro-list-hist.line = 0
                      then (v-seq + 1)
                      else v-seq)
              v-no-hist = v-no-hist + 1
              .
            end.
            if v-no-hist = 1 then v-no-hist = 0.
            run rs-do in this-procedure (input yes
                                      , input p-step
                                      , input macro-list-hist.option_
                                      , input macro-list-hist.status_
                                      , input get-line-mode(macro-list-hist.hist-mode)
                                      , input v-temp-seq
                                      ) no-error .
            if error-status:error then do:
              assign
              v-rs-do-error = yes.
            end.
            if get-line-mode(macro-list-hist.hist-mode) = 'ОСТАВИТЬ':U then do:
              run proc-b-rest-2 in this-procedure .
              run MyEnable in this-procedure .
            end.
            for each buf_dc-list-hist where
                    buf_dc-list-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_dc-list-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_dc-list-hist.num-recs
               buf_macro-list-hist.num-add = buf_dc-list-hist.num-add
               buf_macro-list-hist.num-ignored = buf_dc-list-hist.num-ignored
               .
            end.
            if v-rs-do-error then do:
              run MyEnable in this-procedure .
              return ("error" + chr(4) + return-value).
            end.
            v-id = macro-list-hist.id.
          end.
        end.
      end.
    END CASE.
  end.
end.
end procedure.
procedure proc-b-rest-2 :
  do
  on error undo, return error
  :
    for each dc-list:
      if dc-list.to-del = ? then do:
        assign
        dc-list.to-del = no
        .
      end.
      else do:
        delete dc-list.
      end.
    end.
    tot-lns = lns-cnt.
  end.
end procedure.
PROCEDURE proc-expand :
define input parameter p-shift as integer no-undo .
define input parameter p-from as integer no-undo .
define input parameter p-to as integer no-undo .
define input parameter p-forcer-name as character no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable lh as widget-handle no-undo .
define variable ii as INTEGER no-undo .
ASSIGN
fh = frame Dialog-Frame:first-child
hh = fh:first-child
.
CASE v-expand:
  WHEN YES THEN DO:
    ASSIGN
    v-expand = NO.
    DO ii = 1 TO NUM-ENTRIES(v-downed):
      ASSIGN
      hh              = WIDGET-HANDLE(ENTRY(ii, v-downed))
      hh:ROW          = (hh:ROW - p-shift).
      hh:height-chars = (if hh:type = "browse" then (hh:height-chars + p-shift) else hh:height-chars).
    END.
  END.
  WHEN NO THEN DO:
    v-expand = YES.
    v-downed = ''.
    _do:
    do while valid-handle(hh):
      IF lookup(hh:type, "radio-set,browse,button,fill-in,literal,text,rectangle") > 0
       AND hh:ROW >= p-from
       AND hh:ROW <= p-to
       and lookup(hh:name, p-forcer-name) = 0
       THEN DO:
        hh:height-chars = (if hh:type = "browse" then (hh:height-chars - p-shift) else hh:height-chars).
        hh:ROW          = (hh:ROW + p-shift).
        ASSIGN
        v-downed = v-downed + chr(44) + STRING(hh).
        IF hh:TYPE = "fill-in"
        AND valid-handle(hh:side-label-handle) THEN dO:
          assign
          lh = hh:SIDE-LABEL-HANDLE
          lh:ROW = lh:ROW + p-shift
          v-downed = v-downed + chr(44) + STRING(lh)
          .
         END.
       END.
       hh = hh:next-sibling.
    END.
    v-downed = trim(v-downed, chr(44)).
  END.
END CASE.
END PROCEDURE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup("automain", parparentproc:file-name, ".") > 0 then do:
    v-no-context = yes.
  end.
  else do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-docs-all
    )  .
end.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_company':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-docs-cmp
    )  .
end.
  run get-report-num in parparentproc ( output g#report-num ).
  assign
    line-rec = ?
    .
    assign
    n-c:radio-buttons in frame Dialog-Frame =
    "Номер" + chr(44) + 'карта':U + chr(44) +
    "Код кл." + chr(44) + 'Контрагент':U
    RS-status:radio-buttons = "Текущие&+" + chr(44) + 'тек':U + chr(44) +
                              "Все&!" + chr(44) + 'все':U + chr(44) +
                              "Удаленные&-" + chr(44) + 'удал':U + chr(44) +
                              "Блокированные&0" + chr(44) + 'блок':U
    RS-status = 'тек':U
    .
  ASSIGN b-save:MENU-MOUSE = 1.
  ASSIGN b-print:MENU-MOUSE = 1.
  assign b-macro:menu-mouse = 1.
  run proc-fill-temp-list in this-procedure .
  if lookup(bttns, "hide") > 0 then do:
    return.
  end.
  RUN Myenable in this-procedure .
  APPLY "VALUE-CHANGED" to n-c.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
output to value (p-full-path).
for each dc-list:
  export
  dc-list.d-card
  dc-list.cli-type
  dc-list.cli-code.
end.
output close.
end procedure.
procedure cb_fill-lob-res-list-macro :
define input  parameter p-full-path as character no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
output to value (p-full-path).
for each buf_dc-list-hist:
    export
    buf_dc-list-hist.
end.
output close.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY dsp-rs NameOrCode n-c RS-Status ed-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs BR-option B-exit B-save B-print B-hist B-lkp B-clr B-Help B-add
         B-del B-rest B-macro B-stop B-clear-macro B-record NameOrCode n-c
         RS-Status BR-list ed-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-list FOR EACH dc-list       WHERE dc-list.emitent-host-code = p-curr-host-code NO-LOCK     BY dc-list.d-card INDEXED-REPOSITION.     open query br-option for each temp-list no-lock .
END PROCEDURE.
procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
define buffer buf_macro-list-hist for macro-list-hist.
if can-find(first macro-list-hist) then do:
  run gbl/d-askw.w ( input "Сохранение макроса"
                ,input "Выберите какие действия по формированию списка Вы хотите сохранить"
                ,input "|"
                ,input "Посл.ЗАПИСЬ|Все|Отказ"
                ,input "Действия при нажатой кнопке ЗАПИСЬ|ВСЯ последовательность действий|Отказ"
                ,input 1
                ,input 3
                ,output v-option).
  if v-option = 3 then return no-apply.
  v-option = 1.
end.
else do:
  message
  "Будет сохранена в файл ВСЯ последовательность действий по формированию списка" skip
  view-as alert-box question buttons yes-no update glog.
  v-option = 2.
  if not glog then do:
    return no-apply.
  end.
end.
  do
  on error undo, return error
  :
  assign
    f-name = "default.dcm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка карт *.dcm" "*.dcm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "dcm".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка карт.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_dc-list-hist:
      export stream PrnLibStream
      buf_dc-list-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure.
procedure m_dc-save-db-proc :
define variable v-rid-list as character no-undo .
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input 'list':U
                   ,input "dc-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
end procedure.
procedure m-macros-save-db-proc :
define variable v-rid-list as character no-undo .
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input 'list-macro':U
                   ,input "dc-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
end procedure.
PROCEDURE MyEnable :
define variable v-start as logical no-undo .
define buffer buf_temp-list for temp-list.
define variable v-recid0 as recid no-undo.
define buffer buf_dc-list-hist for dc-list-hist.
find first buf_dc-list-hist where buf_dc-list-hist.id = 0 no-error.
if available buf_dc-list-hist then
assign
frame Dialog-Frame:title = substitute("СПИСОК  КАРТ &1",  string(buf_dc-list-hist.des, "X(60)"))
.
br-option:column-scrolling in frame Dialog-Frame  = no.
  assign
  frame Dialog-Frame:title = p-title
  .
if tot-lns = ? then do:
  v-start = yes.
  for each l-dc-list :
    accumulate l-dc-list.d-card (count).
  end.
  tot-lns = (accum count l-dc-list.d-card).
  if tot-lns > 0 then do:
    find last  buf_dc-list-hist no-error .
    v-seq = (if available buf_dc-list-hist then buf_dc-list-hist.id else 0)  + 1.
    run create-dc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input 'S':U
                                          , input substitute("# Исходный список: &1 строк", tot-lns)
                                          , input tot-lns
                                          , input "start":U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
  else do:
    line-mode = 'ДОБАВЛЕНИЕ':U.
    for each buf_dc-list-hist:
      delete buf_dc-list-hist.
    end.
    v-seq = 1.
    run create-dc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input "# Исходный список карт пуст."
                                          , input tot-lns
                                          , input 'start':U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
end.
assign
nameorcode = ""
RS-list-method = "single".
find first buf_temp-list no-lock where
            buf_temp-list.fvalue = "single".
assign
v-recid0 = recid(buf_temp-list).
open query br-option for each temp-list no-lock .
  if v-seq > 1 then
  find last buf_dc-list-hist no-lock where
            buf_dc-list-hist.id = (v-seq - 1)
       and  buf_dc-list-hist.line = 0 no-error .
  DISPLAY br-option
  (if available buf_dc-list-hist
  then buf_dc-list-hist.des
  else '') @ dsp-rs
  RS-Status WITH FRAME Dialog-Frame.
  ENABLE
  b-macro  when v-start
  b-record when v-start
  b-exit b-add b-hist b-help br-option br-list RS-Status WITH FRAME Dialog-Frame.
  if v-start then do:
    hide
    b-stop
    b-clear-macro
    in frame Dialog-Frame.
  end.
  v-start = no.
  hide nameorcode in frame Dialog-Frame .
if lookup('list':U, bttns) > 0 then do:
    menu-item m_dc-save-db:sensitive  in menu menu-b-save = no.
end.
if lookup('list-macro':U, bttns) > 0 then do:
    menu-item m-macros-save-db:sensitive  in menu menu-b-save = no.
end.
  reposition br-option to recid v-recid0.
  if tot-lns > 0 then
    ENABLE
    b-print
    b-rest
    b-save
    b-del
    b-lkp
    b-clr
    n-c
    nameorcode
    WITH FRAME Dialog-Frame.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr nameorcode WITH FRAME Dialog-Frame.
end.
  if tot-lns = ? or tot-lns = 0 then do:
    hide nameorcode in frame Dialog-Frame .
  end.
  VIEW FRAME Dialog-Frame.
  run openbr in this-procedure .
    if line-rec <> ? then
    reposition br-list to recid line-rec no-error.
  display tot-lns @ f-tot-lns with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr :
        Open query br-list
        for each dc-list No-LOCK indexed-reposition.
APPLY "ENTRY" to br-list in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
line-mode = 'ДОБАВЛЕНИЕ':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.dis-card where rowid(ub.dis-card) = p-rowid no-lock no-error .
  end.
  else do:
    run ref/discards.w ( input parparentproc
                        ,input "b-sel,b-add"
                        ,input 'все':U
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input '':U
                        ,input ?
                        ,output ref-list).
    apply "entry" to br-list in frame Dialog-Frame.
    if ref-list = "" then return error.
    find ub.dis-card where recid (ub.dis-card) = integer (ref-list) no-lock.
  end.
  if available dis-card then do:
    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
  end.
  else do:
    return error "Нет в БД такой карты".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable glog as logical no-undo .
define variable v-rep-rec as recid no-undo .
line-mode = 'удаление':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find first ub.dis-card where rowid(ub.dis-card) = p-rowid no-error.
    if not available ub.dis-card then return error "Нет в БД такой карты".
    find first dc-list where dc-list.d-card = ub.dis-card.d-card no-error.
  end.
  if available dc-list then do:
    line-rec = recid (dc-list).
    get next br-list.
    if available dc-list then v-rep-rec = recid (dc-list).
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available dc-list then v-rep-rec = recid (dc-list).
    end.
    reposition br-list to recid line-rec no-error.
    tot-lns = tot-lns - 1.
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
    delete dc-list.
    line-rec = v-rep-rec.
    run Myenable in this-procedure .
  end.
  else do:
    tot-lns = tot-lns - 1.
    run Myenable  in this-procedure .
    return error "Нет в списке карт такой карты".
  end.
end.
else do:
  glog = no.
  message
  "Удалить карты из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if not glog then  return error.
  run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable glog as logical no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
line-mode = 'ОСТАВИТЬ':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find first ub.dis-card where rowid(ub.dis-card) = p-rowid no-error.
    if not available ub.dis-card then return error substitute("Нет в БД такой карты").
    find first dc-list where dc-list.d-card = ub.dis-card.d-card no-error.
  end.
  if available dc-list then do:
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return no-apply.
    end.
    line-rec = recid (dc-list).
    v-seq = 1.
    for each buf_dc-list-hist:
      delete buf_dc-list-hist.
    end.
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
    for each dc-list:
      if line-rec <> recid (dc-list) then delete dc-list.
    end.
    tot-lns = 1.
    run Myenable  in this-procedure .
 end.
  else do:
    return error substitute("Нет в списке такой карты").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message "Оставить карты в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
  for each dc-list:
    if dc-list.to-del = ? then do:
      assign
      dc-list.to-del = no
      .
    end.
    else do:
      delete dc-list.
    end.
  end.
  tot-lns = lns-cnt.
  run Myenable  in this-procedure .
  message
  "Оставлено строк :" lns-cnt skip(0)
  string(if lns-ignore <> 0
  then ("Проигнорировано строк :" + string(lns-ignore))
  else "":U)
  .
end.
END PROCEDURE.
procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-art like ub.goods.artic no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable imp-chk-type as integer no-undo.
define variable imp-d-card as character no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-tbl-row          as rowid no-undo .
define variable v-tbl-name         as character no-undo .
define buffer buf_dc-list-hist for dc-list-hist.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
do
on error undo, return error
:
  find first buf_dc-list-hist where
          buf_dc-list-hist.id = p-id
      AND buf_dc-list-hist.item_ <> '':U .
if rs-list-method = "clob-data" then do:
  run gen-row-keyr in this-procedure (
   input  buf_dc-list-hist.item_
  ,input  ?
  ,input  "ub"
  ,input  ?
  ,input NO-LOCK
  ,output v-tbl-row
  ,output v-tbl-name  ) no-error.
  if error-status :error then do:
    message
    "Ошибка при поиске хранимого файла"
    view-as alert-box error.
    return error.
  end.
  find first buf_clob-bind no-lock where
            rowid(buf_clob-bind) = v-tbl-row .
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if error-status :error then do:
    message
    "Ошибка при пополучении хранимого файла"
    view-as alert-box error.
    return error.
  end.
  run gbl/_tmpfile.p ( input ""
                ,input "tmp"
                ,output v-file-name) .
  copy-lob from object buf_clob-data.cdata
  to file v-file-name.
end.
  run gbl/filename.p
  (input  (if rs-list-method = "clob-data" then v-file-name else buf_dc-list-hist.item_  )
  ,output v-full-path
  ,output v-path
  ,output v-file-name
  ,output v-file-name-no-ext
  ,output v-file-name-ext
  ) no-error .
  if error-status:error then do:
  end.
  else do:
    input stream sout from value (v-full-path).
      CASE rs-list-method:
        when "doc-list" then do:
          repeat:
          import stream sout imp-doc-code imp-doc-type no-error.
          if imp-doc-type <>  'переоценка':U then do:
            find first ub.trn-doc no-lock where
                      ub.trn-doc.doc-code = imp-doc-code No-error.
            if available ub.trn-doc
            and
            (ub.trn-doc.ext-doc-type = 'es':U
             or ub.trn-doc.ext-doc-type = 'rs':U) then do:
              for each ub.chk-doc no-lock where
                      ub.chk-doc.out-code = (if ub.trn-doc.ext-doc-type = 'es':U
                                          then ub.trn-doc.doc-code
                                          else ub.trn-doc.out-code) and ub.chk-doc.d-card <> "":U,
                  first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.chk-doc.d-card:
                run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
              end.
            end.
            else if ub.trn-doc.d-card <> "":U and ub.trn-doc.d-card <> ? then do:
              find first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.trn-doc.d-card no-error .
              if available ub.dis-card then
                run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
      end.
      when "cli-list" then do:
        repeat:
          import stream sout imp-type imp-code no-error.
          find ub.clients where
              ub.clients.obj-type = imp-type and
              ub.CLIENTS.OBJ-code = imp-code
              no-lock no-error.
          if available ub.CLIENTS then do:
            for each ub.dis-card No-LOCK WHERE
                      ub.dis-card.cli-type = ub.clients.obj-type AND
                      ub.dis-card.cli-code = ub.clients.obj-code:
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
      end.
      when "chk-list" then do:
        repeat:
          import stream sout imp-doc-code imp-chk-type no-error.
          if imp-chk-type = integer('1':U)
          or imp-chk-type = integer('6':U)
          or imp-chk-type = integer('96':U)
          or imp-chk-type = ? then do:
            find first ub.chk-doc no-lock where
                      ub.chk-doc.doc-code = imp-doc-code No-error.
            if available ub.chk-doc and ub.chk-doc.d-card <> "":U then do:
              find first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.chk-doc.d-card no-error.
              if available ub.dis-card then
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
      end.
      when "file"
      or
      when "clob-data"
      then do:
        repeat:
          import stream sout imp-d-card no-error.
          find ub.dis-card where
              ub.dis-card.d-card = imp-d-card no-lock no-error.
          if available ub.dis-card then run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
        if rs-list-method = "clob-data" then do:
          os-delete value(v-full-path) .
        end.
      end.
    end CASE.
  end.
  input stream sout close.
  assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
end.
end procedure.
PROCEDURE proc-b-save :
define input parameter loc-save-option as character no-undo.
define variable v-frame-width as integer no-undo.
define variable v-default-valid-date as date no-undo .
define variable v-codir as character no-undo .
define variable v-prefix as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-default-valid-date-chr as character no-undo .
define variable glog as logical no-undo .
define variable v-full-number as character no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_clients for ub.clients.
case loc-save-option:
  when "dc-list":U then do:
    assign
    f-name = "default.dc"
    glog = yes
    .
    system-dialog get-file f-name
    filters "Списки дисконтных карт *.dc" "*.dc"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "dc".
    if not glog then do:
      apply "entry" to br-list in frame Dialog-Frame.
      return no-apply.
    end.
    output to value (f-name).
    for each dc-list:
      export
      dc-list.d-card
      dc-list.cli-type
      dc-list.cli-code
      .
    end.
    output close.
  end.
  when "dc-list-macros-db" then do:
    run m-macros-save-db-proc in this-procedure .
  end.
  when "dc-list-db" then do:
    run m_dc-save-db-proc in this-procedure .
  end.
  when "excel":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
      :
      run str/dcl-prn.p (
                       input parparentproc
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input "excel":U
                      ,output v-Frame-Width) no-error.
        assign make-excel = no.
        run waitfram-hide in this-procedure .
    end.
  end.
  when "to-make":U then do:
    assign
    f-name = "default.crd"
    glog = yes
    .
    system-dialog get-file f-name
    filters "Списки ДК для изготовления *.crd" "*.crd"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "crd".
    if not glog then do:
      apply "entry" to br-list in frame Dialog-Frame.
      return no-apply.
    end.
    run gbl/crd-file.w (output v-codir, output v-default-valid-date, output v-prefix) no-error .
    if error-status:error
    or return-value = "error" then do:
      apply "entry" to br-list in frame Dialog-Frame.
      return no-apply.
    end.
    if session:set-wait-state( "COMPILER" )  then .
    CASE v-codir:
      when '':U
      or when "1251":U
      then do:
        output to value (f-name).
      end.
      when "koi8-r" then do:
        output to value (f-name) convert target "koi8-r".
      end.
      when "ibm866" then do:
        output to value (f-name) convert target "ibm866".
      end.
    END CASE.
    output stream slog to value("crd-file.log") .
    for each dc-list:
      if dc-list.mask-card then do:
        put stream slog unformatted substitute("карта &1 - маска: пропускаем..."
                                              , dc-list.d-card) skip.
        next.
      end.
      find first buf_clients no-lock where
                buf_clients.obj-type = dc-list.cli-type
            AND  buf_clients.obj-code = dc-list.cli-code no-error .
      if available buf_clients
      and buf_Clients.obj-name <> '':U
      then do:
        if length(dc-list.d-card)  +  length(v-prefix) + 1 > 19 then do:
          put stream slog unformatted substitute("карта &1 - длина с учетом префикса &2 и КЦ больше 19 символов: пропускаем..."
                                                , dc-list.d-card
                                                , v-prefix) skip.
          next.
        end.
        run gbl/pluhnalg.p (input (v-prefix + dc-list.d-card + 'C')
                        ,output v-full-number) no-error .
        if error-status:error then do:
          put stream slog unformatted substitute("карта &1 - ошибка при вычислении КЦ &2: пропускаем..."
                                                , dc-list.d-card
                                                , error-status:get-message(1) ) skip.
          next.
        end.
        if v-codir <> '':U then do:
          put unformatted
          substitute("~~1%&1?", string(buf_clients.obj-name, "X(30)")) skip
          .
        end.
        put unformatted
        substitute("~~2;&1=&2&3700&4?"
                  , v-full-number
                  , (if dc-list.valid-date <> ?
                    then string(year(dc-list.valid-date) - 2000, "99")
                    else string(year(v-default-valid-date) - 2000, "99")
                    )
                  , (if dc-list.valid-date <> ?
                    then string(month(dc-list.valid-date), "99")
                    else string(month(v-default-valid-date), "99")
                    )
                  , fill(chr(32), 5 )
                  ) skip.
      end.
      else do:
        put stream slog unformatted
        substitute("карта &1 - не найден клиент &2&3 или нет фамилии/названия: пропускаем..."
                  , dc-list.d-card
                  , dc-list.cli-type
                  , dc-list.cli-code) skip.
        next.
      end.
    end.
    output close.
    output stream slog close.
    if session:set-wait-state( "" )  then .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-find-nameorcode :
case n-c:
    when 'карта':U then do:
    if last-event:label = "Ctrl-J" then
        find next l-dc-list no-lock where
                  l-dc-list.d-card begins nameorcode no-error.
    else
        find first l-dc-list no-lock where
                  l-dc-list.d-card begins nameorcode no-error.
    end.
    when 'Контрагент':U then do:
    if last-event:label = "Ctrl-J" then
        find next l-dc-list no-lock where
                  l-dc-list.cli-code = integer(nameorcode) no-error.
    else
        find first l-dc-list no-lock where
                  l-dc-list.cli-code = integer(nameorcode) no-error.
    end.
end case.
if available l-dc-list then do:
  line-rec = recid (l-dc-list).
  reposition br-list to recid line-rec no-error.
    apply "value-changed" to br-list in frame Dialog-Frame.
end.
else do:
  message "Строка не найдена."
          view-as alert-box error.
end.
END PROCEDURE.
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable ii as integer no-undo.
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable glog as logical no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable f-name as char init "default.trn" no-undo.
define variable v-host-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_dc-list-hist for dc-list-hist.
 v-no-hist = - 1.
if rs-list-method = "single" then
run Myenable  in this-procedure .
else do:
  v-no-hist = 0.
  case rs-list-method:
    when "company" then do:
      glog = yes.
      message
      substitute("Все карты с эмитентом-фирмой &1", p-curr-host-code)
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return no-apply.
      end.
      v-no-hist = 1.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Карты фирмы &1 &2', v-host-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input "company"
                                          , input string(p-curr-host-code)
                                          , input ?
                                          ).
    end.
    when "global" then do:
      glog = yes.
      message
      substitute("Все глобальные карты")
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-no-hist = 1.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Глобальные карты &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'global'
                                          , input string(0)
                                          , input ?
                                          ).
    end.
    when "type" then do:
      glog = yes.
      message
      "Все карты выбранных типов."
       view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      GRP-list = "".
      run ref/dc-types.w (
                       input parparentproc
                      ,input "":U
                      ,input "b-sel,b-mark":U
                      ,input 0
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input-output ref-list
                      ).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      dsp-rs = "".
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.dis-card-type where recid (ub.dis-card-type) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Тип &1 Эмитент &2: &3"
                              , ub.dis-card-type.type
                              , ub.dis-card-type.emitent-host-code
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = 'dis-card-type':U
          v-bh       = buffer dis-card-type:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип &1:"
                                , stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("Тип &1 Эмитент &2"
                                , ub.dis-card-type.type
                                , ub.dis-card-type.emitent-host-code
                                )
            v-item     = '':U
            v-tbl-name = 'dis-card-type':U
            v-bh       = buffer ub.dis-card-type:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "all" then do:
      glog = yes.
      message "Все карты из справочника карт."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-no-hist = 1.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Все карты &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'all':U
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "card" then do:
      glog = yes.
      message "1 или несколько карт"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      dsp-rs = "".
      run ref/discards.w (
                           input parparentproc
                          ,input "b-sel,b-mark"
                          ,input 'все':U
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input '':U
                          ,input ?
                          ,output ref-list).
      apply "entry" to br-list in frame Dialog-Frame.
      if ref-list = "" then do:
          run MyEnable  in this-procedure .
          return error.
      end.
      v-recs = num-entries (ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.dis-card  where recid (ub.dis-card) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карта :&1 &2", ub.dis-card.d-card, stat-line(rs-status))
          v-item     = '':U
          v-tbl-name = 'dis-card':U
          v-bh       = buffer ub.dis-card:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты : &1", stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("№ карты &1 &2&3", ub.dis-card.d-card, ub.dis-card.cli-type, ub.dis-card.cli-code)
            v-item     = '':U
            v-tbl-name = 'dis-card':U
            v-bh       = buffer ub.dis-card:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "cli" or WHEN "cli-grp" then do:
      if rs-list-method = "cli-grp" then do:
        glog = yes.
        message
        "Карты по 1-й или нескольким групп клиентов"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable  in this-procedure .
          return error.
        end.
        GRP-list = "".
        ref-list = "".
        run ref/cli-grps.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input-output grp-list).
      end.
      else do:
        glog = yes.
        message
        "Карты 1-го или нескольких произвольных клиентов из справочника."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable  in this-procedure .
          return error.
        end.
        run ref/cli-all.w ( input parparentproc
                        ,input "b-sel,b-mark,b-add"
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,output ref-list).
        grp-list = ?.
      end.
      if grp-list <> ? and
      grp-list <> "" then do:
        v-recs = num-entries (grp-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-grp-rec = integer (entry (num-rec, grp-list)).
            find ub.cli-grp where recid (ub.cli-grp) = v-grp-rec no-lock.
            run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Группа клиентов &1: &2", grp-path, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = 'cli-grp':U
            v-bh       = buffer cli-grp:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группы клиентов: &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1", grp-path)
              v-item     = '':U
              v-tbl-name = 'cli-grp':U
              v-bh       = buffer ub.cli-grp:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      else if ref-list <> "" and  ref-list <> ? then do:
        v-recs = num-entries (ref-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.clients where recid (ub.clients) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Клиент :&1 &2", ub.clients.obj-name, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = 'clients':U
            v-bh       = buffer ub.clients:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Клиент : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1", clients.obj-name)
              v-item     = '':U
              v-tbl-name = 'clients':U
              v-bh       = buffer ub.clients:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      else do:
        run MyEnable  in this-procedure .
        return error.
      end.
    end.
    when "person" then do:
      glog = yes.
      message
      "Карты всех физических лиц."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Карты ВСЕХ физические лиц. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'person':U
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "waybill" then do:
      glog = yes.
      message
      "Карты контрагентов выбранных документов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run str/all-docs.w (input parparentproc
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-host-code-obj)
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-obj-type)
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-obj-code)
                    ,input (if v-docs-all
                            then 'работа':U
                            else (if v-docs-cmp
                                  then 'фирма':U
                                  else 'объект':U)
                            )
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input 'b-sel,b-mark':U
                    ,input '':U
                    ,input ?
                    ,input ?
                    ,output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.trn-doc where recid (ub.trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты контрагента по документу : &1 &2 &3 &4 № &5 от &6 &7"
                              , ub.trn-doc.doc-type
                              , ub.trn-doc.status_
                              , ub.trn-doc.obj-type
                              , ub.trn-doc.obj-code
                              , ub.trn-doc.doc-code
                              , string (ub.trn-doc.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = 'trn-doc':U
          v-bh       = buffer ub.trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты контрагентов по документам : &1", stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                , ub.trn-doc.doc-type
                                , ub.trn-doc.status_
                                , ub.trn-doc.obj-type
                                , ub.trn-doc.obj-code
                                , ub.trn-doc.doc-code
                                , string (ub.trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'trn-doc':U
            v-bh       = buffer ub.trn-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "inkas" then do:
      glog = yes.
      message
      "Карты по выбранным продажам по объекту."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
                          if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-sel-obj-type
  ,input  v-sel-obj-code
  ,output v-host-code
  )  .
      ref-list = ''.
      run str/salelist.w (
                      input parparentproc
                    , input "b-sel,b-mark"
                    , 'объект':U
                    , v-host-code
                    , v-sel-obj-type
                    , v-sel-obj-code
                    , input-output ref-list).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.inkas where recid (ub.inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты по чекам продажи &1&2 № &3 от &4 &5"
                              , ub.inkas.obj-type
                              , ub.inkas.obj-code
                              , ub.inkas.inkas-code
                              , string (ub.inkas.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = 'inkas':U
          v-bh       = buffer ub.inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты контрагентов по продажам &1&2: &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                , ub.inkas.inkas-code
                                , string (inkas.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'inkas':U
            v-bh       = buffer ub.inkas:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "stop-list" then do:
      glog = yes.
      message
      "Карты выбранных стоплистов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      ref-list = '':U.
      run ref/stop-ls.w ( input parparentproc
                         ,input "b-sel,b-mark"
                         ,input 'все':U
                         ,input-output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find first buf_stop-list where recid (buf_stop-list) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты стоплиста : &1 от &2 &3"
                              , buf_stop-list.stop-list-code
                              , string (buf_stop-list.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = 'stop-list':U
          v-bh       = buffer buf_stop-list:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты стоплистов : &1", stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1 от &2"
                                , buf_stop-list.stop-list-code
                                , string (buf_stop-list.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'stop-list':U
            v-bh       = buffer buf_stop-list:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "chk-doc" then do:
      glog = yes.
      message
      "Карты по выбранным чекам по объекту."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
                          if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      ref-list = ''.
      run str/chk-docs.w (   input parparentproc
                      , input "b-sel,b-mark"
                      , input 'объект':U
                      , input ?
                      , input v-sel-obj-type
                      , input v-sel-obj-code
                      , input "":U
                      , input "":U
                      , input 0
                      , input ?
                      , input ?
                      , input 0
                      , output ref-list).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.chk-doc where recid (ub.chk-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карта чека &1&2 &3 от &4 &5"
                              , v-sel-obj-type
                              , v-sel-obj-code
                              , ub.chk-doc.doc-code
                              , string(ub.chk-doc.chk-date)
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = 'chk-doc':U
          v-bh       = buffer ub.chk-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты чеков &1&2: &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = '':U
            v-bh       = ?
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1 от &2"
                                , ub.chk-doc.doc-code
                                , string (ub.chk-doc.chk-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'chk-doc':U
            v-bh       = buffer ub.chk-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.
    when "attr" or
    when "attr-val"
    then do:
      run trig-attr  in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
    end.
    when "dcp" or
    when "dcp-val"
    then do:
      run trig-dcp  in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
    end.
    when "general-sum-id"
    or
    when "partial-sum-id"
    or
    when "last-change-general-sum-id"
    or
    when "last-change-partial-sum-id" then do:
      run proc-sum-id in this-procedure ( input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "cli-list" then do:
      glog = yes.
      message
      "Все карты для клиентов из сохраненного в файле списка клиентов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки клиентов *.cli" "*.cli"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "cli".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты клиентов из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "doc-list" then do:
      glog = yes.
      message
      "Все карты для документов из сохраненного в файле списка документов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки документов *.trn" "*.trn"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "trn".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты документов из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "chk-list" then do:
      glog = yes.
      message
      "Все карты для чеков из сохраненного в файле списка чеков."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки документов *.chk" "*.chk"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "chk".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты чеков из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "deleted" then do:
      if RS-status = 'текущие':U then do:
        message
        "Переключатель <СТАТУС> стоит в положениии <Текущие>" skip
        "Вы не cможете выбрать ни одну карту"
        view-as alert-box error .
        run MyENable  in this-procedure .
        return error.
      end.
      glog = yes.
      message
      "Все удаленные карты."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("ВСЕ удаленные карты &1", stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'deleted':U
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "file" then do:
      glog = yes.
      message "Все карты из ранее сохраненного в файле списка."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки дисконтных карт *.dc" "*.dc"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "dc".
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
  end.
  when "clob-data" then do:
    glog = yes.
    message "Все карты из ранее сохраненного в БД списка"
    skip stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      run Myenable in this-procedure.
      return error.
    end.
    run ref/clobbnds.w ( input parparentproc
                        ,input this-procedure:handle
                        ,input 'b-sel'
                        ,input "uniq-key-rec"
                        ,input ""
                        ,input 'list':U
                        ,input 'dc-list'
                        ,input -1
                        ,input-output v-rid-list) no-error.
    if v-rid-list = '' then do:
      run Myenable in this-procedure.
      return error.
    end.
    find first buf_clob-bind no-lock where
              recid(buf_clob-bind) = integer(v-rid-list) .
    run gen-key-rec in this-procedure ( input 'clob-bind':U
                                        ,input (buffer buf_clob-bind:handle)
                                        ,output v-uniq-key-rec).
    run create-dc-list-hist in this-procedure (
                                          input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
                                        , input substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name_, stat-line(rs-status))
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input v-uniq-key-rec
                                        , input '':U
                                        , input ?)
                                        .
  end.
  WHEN "FILTER" THEN DO:
      run trig-filter  in this-procedure no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
  END.
end case.
if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when 1 then do:
        run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      when 2 then do:
        run proc-b-del in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      when 3 then do:
        run proc-b-rest in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      otherwise do:
        assign
        dsp-rs = "":U.
        run MyEnable in this-procedure .
        return error.
      end.
    END CASE.
  end.
  assign
  rs-list-method = temp-list.fvalue
  .
  find last buf_dc-list-hist no-lock where
            buf_dc-list-hist.id = (v-seq - 1)
      and  buf_dc-list-hist.line = 0 no-error .
  DISPLAY
  (if available buf_dc-list-hist
  then buf_dc-list-hist.des
  else '') @ dsp-rs
  with frame Dialog-Frame.
  if tot-lns = 0
  then do:
    run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
  end.
end.
END PROCEDURE.
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable grp-path as character no-undo .
define variable v-host-code as integer no-undo .
define variable v-dt-code as integer no-undo .
define variable v-r-b as character no-undo .
define variable v-field as character no-undo .
define variable v-low as decimal no-undo .
define variable v-high as decimal no-undo .
define variable v-acc as decimal no-undo .
define variable v-next as logical no-undo .
define variable v-last-change-date as date no-undo .
define variable v-cond as character no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dc-list-hist for dc-list-hist.
do
on error undo, return error return-value
:
assign
lns-cnt = 0
lns-ignore = 0
v-num-add  = 0
v-num-ignored = 0
tot-lns = (if line-mode = 'ОСТАВИТЬ':U then 0 else tot-lns)
.
run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame Dialog-Frame = 12.
case rs-list-method:
  when "card" then do:
    for each buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
        and  buf_dc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find ub.dis-card where rowid (ub.dis-card) = v-rowid no-lock.
      if available ub.dis-card then
      run ex-dc(input rs-list-method, input rs-status, input line-mode).
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "cli-grp" then do:
    for each buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
        and  buf_dc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      grp-path = "".
      find first ub.cli-grp no-lock where rowid(ub.cli-grp) = v-rowid.
      grp-path = ''.
      run cli-grplib-get-full-name in this-procedure (cli-grp.node-code, output grp-path).
      for each ub.clients no-lock where ub.clients.grp-name begins grp-path,
          each ub.dis-card no-lock where
                ub.dis-card.cli-type = ub.clients.obj-type
            AND ub.dis-card.cli-code = ub.clients.obj-code:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "cli" then do:
    for each buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
        and  buf_dc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first ub.clients no-lock where rowid(ub.clients) = v-rowid.
      for each ub.dis-card no-lock where
                ub.dis-card.cli-type = ub.clients.obj-type
            AND ub.dis-card.cli-code = ub.clients.obj-code:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "global":U then do:
   find first buf_dc-list-hist where
               buf_dc-list-hist.id = p-id .
    for each ub.dis-card no-lock where ub.dis-card.emitent-host-code = 0:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  when "company":U then do:
    find first buf_dc-list-hist where
               buf_dc-list-hist.id = p-id .
    for each ub.dis-card no-lock where ub.dis-card.emitent-host-code = p-curr-host-code:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "type":U then do:
    for each buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
        and  buf_dc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find ub.dis-card-type where
            rowid (ub.dis-card-type) = v-rowid no-lock.
      for each ub.dis-card where
                ub.dis-card.type = ub.dis-card-type.type no-lock:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    END.
  end.
  when "person" then do:
    find first buf_dc-list-hist where
               buf_dc-list-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = 'чел':U no-lock,
        each ub.dis-card where
            ub.dis-card.cli-type = ub.clients.obj-type AND
            ub.dis-card.cli-code = ub.clients.obj-code:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "waybill" then do:
  for each buf_dc-list-hist where
            buf_dc-list-hist.id = p-id
      and  buf_dc-list-hist.item_ <> '':U:
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
    find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
    if available ub.trn-doc then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = ub.trn-doc.cli-type AND
                ub.clients.obj-code = ub.trn-doc.cli-code No-ERROR.
      if avail ub.clients then do:
        for each ub.dis-card No-LOCK WHERE
                ub.dis-card.cli-type = ub.clients.obj-type AND
                ub.dis-card.cli-code = ub.clients.obj-code:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  end.
  when "stop-list" then do:
  for each buf_dc-list-hist where
            buf_dc-list-hist.id = p-id
      and  buf_dc-list-hist.item_ <> '':U:
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
    find first buf_stop-list no-lock where
              rowid(buf_stop-list) = v-rowid no-error.
    if available buf_stop-list
    and buf_stop-list.classif-type = 'dis-card':U
    then do:
      for each buf_stop-list-line no-lock where
              buf_stop-list-line.classif-type = buf_stop-list.classif-type
          and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code,
          first ub.dis-card no-lock where
                ub.dis-card.d-card = buf_stop-list-line.charkey_one:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  end.
  when "inkas" then do:
  for each buf_dc-list-hist where
            buf_dc-list-hist.id = p-id
      and  buf_dc-list-hist.item_ <> '':U:
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
    find first ub.inkas no-lock where
              rowid(ub.inkas) = v-rowid no-error.
    if available ub.inkas then do:
      for each ub.chk-doc no-lock where
              ub.chk-doc.out-code = ub.inkas.inkas-code and ub.chk-doc.d-card <> "":U,
        first ub.dis-card no-lock where ub.dis-card.d-card = ub.chk-doc.d-card:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  end.
  when "chk-doc" then do:
    for each buf_dc-list-hist where
              buf_dc-list-hist.id = p-id
        and  buf_dc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_dc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first ub.chk-doc no-lock where
                rowid(ub.chk-doc) = v-rowid no-error.
      if available ub.chk-doc then do:
        find first ub.dis-card no-lock where ub.dis-card.d-card = ub.chk-doc.d-card no-error .
        if available ub.dis-card then do:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "attr" or when "attr-val" then do:
    find first buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
         AND buf_dc-list-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_dc-list-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_dc-list-hist.item_, chr(3)))
    v-attr-code = entry(3, buf_dc-list-hist.item_, chr(3))
    vvalue = (if rs-list-method = "attr" then '':U else entry(4, buf_dc-list-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
      _attr:
      for each ub.clients-attr No-LOCK WHERE
                ub.clients-attr.attr-code = v-attr-code,
        each ub.dis-card no-lock where
            ub.dis-card.cli-type = ub.clients-attr.obj-type
        and ub.dis-card.cli-code = ub.clients-attr.obj-code:
        if rs-list-method = "attr-val" then do:
          run clntattr-value in this-procedure (input ub.clients-attr.obj-type,
                            input ub.clients-attr.obj-code,
                            input v-attr-code,
                            output vvalue1,
                            output vtype1).
          if vvalue1 <> vvalue then NEXT _attr.
        end.
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "dcp" or when "dcp-val" then do:
    find first buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
         AND buf_dc-list-hist.item_ <> '':U no-error .
    assign
    v-dtm-code = integer(entry(1, buf_dc-list-hist.item_, chr(3)))
    v-dt-code = integer(entry(2, buf_dc-list-hist.item_, chr(3)))
    v-node-code = integer(entry(3, buf_dc-list-hist.item_, chr(3)))
    vvalue = (if rs-list-method = "dcp" then '':U else entry(4, buf_dc-list-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
      if rs-list-method = "dcp-val" then do:
        find first buf_prop-map no-lock where
                  buf_prop-map.dtm-code = v-dtm-code
              and buf_prop-map.node-code = v-node-code no-error.
      end.
      if rs-list-method = "dcp"
      or (rs-list-method = "dcp-val"
      and available buf_prop-map) then do:
      _attr:
        for each buf_dis-card-property No-LOCK WHERE
                  buf_dis-card-property.dtm-code = v-dtm-code
              and (v-dt-code = ? or buf_dis-card-property.dt-code = v-dt-code)
              and (v-node-code = ? or buf_dis-card-property.node-code = v-node-code),
          first ub.dis-card no-lock where
              ub.dis-card.d-card = buf_dis-card-property.d-card
          :
          if rs-list-method = "dcp-val" then do:
            case buf_prop-map.node-value-type:
              when 'character':U then do:
                  if buf_dis-card-property.property-value-character <> vvalue then next.
              end.
              when 'date':U then do:
                if buf_dis-card-property.property-value-date <> date(vvalue) then next.
              end.
              when 'decimal':U then do:
                if buf_dis-card-property.property-value-decimal <> decimal(vvalue) then next.
              end.
              when 'integer':U then do:
                if buf_dis-card-property.property-value-integer <> integer(vvalue) then next.
              end.
              when 'character':U then do:
                if buf_dis-card-property.property-value-logical <> logical(vvalue) then next.
              end.
            end case.
          end.
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
        assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
      end.
    end.
  end.
  when "general-sum-id"
  or
  when "partial-sum-id" then do:
    find first buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
         AND buf_dc-list-hist.item_ <> '':U no-error .
    assign
    v-dt-code = integer(entry(1, buf_dc-list-hist.item_, chr(3)))
    v-host-code = integer(entry(2, buf_dc-list-hist.item_, chr(3)))
    v-obj-type = entry(3, buf_dc-list-hist.item_, chr(3))
    v-obj-code = integer(entry(4, buf_dc-list-hist.item_, chr(3)))
    v-r-b = entry(5, buf_dc-list-hist.item_, chr(3))
    v-field = entry(6, buf_dc-list-hist.item_, chr(3))
    v-field = (if v-field = 'num-chk' then v-field else replace(v-field, 'rubl':U, v-r-b))
    v-low = decimal(entry(7, buf_dc-list-hist.item_, chr(3)))
    v-high = decimal(entry(8, buf_dc-list-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do:
      message error-status:error error-status:get-message(1) view-as alert-box .
    end.
    else do:
      if v-obj-code = 0 then do:
        if v-host-code = 0 then do:
          _dh0:
          for each ub.dis-host no-lock where ub.dis-host.dt-code = v-dt-code
            break
            by ub.dis-host.d-card
            by ub.dis-host.dt-code
            by ub.dis-host.host-code :
            if first-of(ub.dis-host.d-card) then do:
              v-acc =0.
              v-next = no.
              if ub.dis-host.host-code = 0  then do:
                if buffer ub.dis-host:buffer-field(v-field):buffer-value >= v-low
                and buffer ub.dis-host:buffer-field(v-field):buffer-value <= v-high then do:
                    find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                end.
                v-next = yes.
              end.
            end.
            if not v-next then do:
              v-acc = v-acc + buffer ub.dis-host:buffer-field(v-field):buffer-value.
            end.
            if last-of(ub.dis-host.d-card) then do:
              if v-next then do:
              end.
              else do:
                if v-acc >= v-low
                and v-acc <= v-high then do:
                    find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                end.
              end.
            end.
          end.
        end.
        _dh:
        for each ub.dis-host no-lock where
                ub.dis-host.host-code = v-host-code
             and ub.dis-host.dt-code = v-dt-code:
          if buffer ub.dis-host:buffer-field(v-field):buffer-value >= v-low
          and buffer ub.dis-host:buffer-field(v-field):buffer-value <= v-high then do:
              find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      else do:
        _do:
        for each ub.dis-obj no-lock where
                ub.dis-obj.obj-type = v-obj-type
            and ub.dis-obj.obj-code = v-obj-code
            and ub.dis-obj.dt-code = v-dt-code :
          if buffer ub.dis-obj:buffer-field(v-field):buffer-value >= v-low
          and buffer ub.dis-obj:buffer-field(v-field):buffer-value <= v-high then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-obj.d-card.
             run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "last-change-general-sum-id"
  or
  when "last-change-partial-sum-id" then do:
    find first buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
         AND buf_dc-list-hist.item_ <> '':U no-error .
    assign
    v-dt-code= integer(entry(1, buf_dc-list-hist.item_, chr(3)))
    v-host-code = integer(entry(2, buf_dc-list-hist.item_, chr(3)))
    v-obj-type = entry(3, buf_dc-list-hist.item_, chr(3))
    v-obj-code = integer(entry(4, buf_dc-list-hist.item_, chr(3)))
    v-cond = entry(5, buf_dc-list-hist.item_, chr(3))
    v-last-change-date = date(entry(6, buf_dc-list-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do:
      message error-status:error error-status:get-message(1) view-as alert-box .
    end.
    else do:
      if v-obj-code = 0 then do:
        if v-host-code = 0 then do:
          _dh0:
          for each ub.dis-host no-lock where
                  ub.dis-host.dt-code = v-dt-code
            break
            by ub.dis-host.d-card
            by ub.dis-host.dt-code
            by ub.dis-host.host-code :
            if first-of(ub.dis-host.d-card) then do:
              v-next = no.
              if ub.dis-host.host-code = 0  then do:
                find last ub.c-dis-host no-lock where
                          ub.c-dis-host.d-card = ub.dis-host.d-card
                      and ub.c-dis-host.dt-code = ub.dis-host.dt-code
                      and ub.c-dis-host.host-code = ub.dis-host.host-code
                      and ub.c-dis-host.corr-user-db-num = 0 no-error.
                if not available ub.c-dis-host then next _dh0.
                if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
                or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
                or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
                or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
                or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
                  find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                  run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                  v-next = yes.
                end.
              end.
            end.
            if last-of(dis-host.d-card) then do:
              if v-next then do:
              end.
              else do:
                find last ub.c-dis-host no-lock where
                          ub.c-dis-host.d-card = dis-host.d-card
                      and ub.c-dis-host.dt-code = dis-host.dt-code
                      and ub.c-dis-host.host-code = dis-host.host-code
                      and ub.c-dis-host.corr-user-db-num = 0 no-error.
                if not available ub.c-dis-host then next _dh0.
                if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
                or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
                or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
                or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
                or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
                  find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                  run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                  v-next = yes.
                end.
              end.
            end.
          end.
        end.
        _dh:
        for each ub.dis-host no-lock where
                ub.dis-host.host-code = v-host-code
            and ub.dis-host.dt-code = v-dt-code:
          find last ub.c-dis-host no-lock where
                    ub.c-dis-host.d-card = dis-host.d-card
                and ub.c-dis-host.dt-code = dis-host.dt-code
                and ub.c-dis-host.host-code = dis-host.host-code
                and ub.c-dis-host.corr-user-db-num = 0 no-error.
          if not available ub.c-dis-host then next _dh.
          if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
          or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
          or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
          or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
          or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
            run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            v-next = yes.
          end.
        end.
      end.
      else do:
        _do:
        for each ub.dis-obj no-lock where
                ub.dis-obj.obj-type = v-obj-type
            and ub.dis-obj.obj-code = v-obj-code
            and ub.dis-obj.dt-code = v-dt-code,
            first ub.clients no-lock where
                 ub.clients.obj-type = ub.dis-obj.obj-type
             and ub.clients.obj-code = ub.dis-obj.obj-code:
          find last ub.c-dis-obj no-lock where
                    ub.c-dis-obj.d-card = ub.dis-obj.d-card
                and ub.c-dis-obj.dt-code = ub.dis-obj.dt-code
                and ub.c-dis-obj.obj-type = ub.dis-obj.obj-type
                and ub.c-dis-obj.obj-code = ub.dis-obj.obj-code
                and ub.c-dis-obj.corr-user-db-num = ub.clients.db-num no-error.
          if not available ub.c-dis-obj then next _do.
          if (v-cond = '=' and ub.c-dis-obj.corr-date = v-last-change-date)
          or (v-cond = '>=' and ub.c-dis-obj.corr-date >= v-last-change-date)
          or (v-cond = '<=' and ub.c-dis-obj.corr-date <= v-last-change-date)
          or (v-cond = '>' and ub.c-dis-obj.corr-date > v-last-change-date)
          or (v-cond = '<' and ub.c-dis-obj.corr-date < v-last-change-date)  then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-obj.d-card.
             run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "cli-list"
  or
  when "doc-list"
  or
  when "chk-list"
  or
  when "file"
  or
  when "clob-data"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end.
  when "deleted" then do:
    find first buf_dc-list-hist where
               buf_dc-list-hist.id = p-id .
    for each ub.dis-card where ub.dis-card.status_ = 'удал':U no-lock:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_dc-list-hist where
             buf_dc-list-hist.id = p-id
         AND buf_dc-list-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_dc-list-hist.item_ , output v-filter-var ).
    run gbl/dc-fill.p (
                     input "Формирование списка по фильтру (без учета сортировки)"
                   , input rs-list-method
                   , input rs-status
                   , input line-mode
                   , input v-filter-var
                   , output lns-cnt
                   , output line-rec
                   )  .
     assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "all" then do:
    find first buf_dc-list-hist where
               buf_dc-list-hist.id = p-id .
    for each ub.dis-card no-lock:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_dc-list-hist.num-add  = lns-cnt - v-num-add                       buf_dc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_dc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_dc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
END CASE.
dsp-rs:fgcolor in frame Dialog-Frame = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
    tot-lns = tot-lns + lns-cnt.
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
  when 'удаление':U then do:
    tot-lns = tot-lns - lns-cnt.
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
end.
if line-mode <> 'ОСТАВИТЬ':U then
  run Myenable in this-procedure .
end.
END PROCEDURE.
PROCEDURE trig-attr :
define input parameter rs-list-method as character no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
define variable v-range              as integer             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable ii as integer no-undo.
define variable v-item               as character           no-undo .
define variable glog                 as logical no-undo .
DEFINE VARIABLE v-attr-code          as character           no-undo .
assign
vattr-codes = ""
vattr-labels = "".
_ii:
DO ii = 1 to num-entries('db,is-superviser':u):
    if rs-list-method = "attr" or rs-list-method  = "attr-val" then do:
       run clntattr-code in this-procedure (input entry(ii, 'db,is-superviser':u),
                       output vtype,
                        output vformat,
                        output vlabel,
                        output vuser-can-edit,
                        output voutput-display,
                        output vother) no-error.
    end.
    if NOT error-status:error anD VOUTPUT-DISPLAY = yes then do:
      if rs-list-method = "attr-val"
      and (lookup('compl=yes', vother, chr(47)) > 0
           or
           lookup('compl=true', vother, chr(47)) > 0) then next _ii.
      assign
      vattr-codes = vattr-codes + chr(44) + entry(ii, 'db,is-superviser':u)
      vattr-labels = vattr-labels + chr(44) + vlabel
      .
    end.
end.
run gbl/d-list.w ("b-sel":U,
            "Выберите атрибут",
             vattr-codes,
             vattr-labels,
             chr(44),
             "":U,
             output v-attr-code).
if v-attr-code = "" then do:
  return error.
end.
glog = yes.
if rs-list-method = "attr" then do:
    run clntattr-tooltip in this-procedure (input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message
    "Карты клиентов с установленным атрибутом " + vlabel
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("Карты c установленным атрибутом &1: &2", vlabel, stat-line(rs-status))
    v-item = '':U + chr(3) + '':U + chr(3) + v-attr-code
    .
end.
if rs-list-method = "attr-val" then do:
    run clntattr-code in this-procedure (input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута клиента" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = 'L':U then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message ("Карты клиентов с атрибутом " + vlabel + " = ":U + vvalue)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("Карты клиентов с атрибутом &1 =&2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item = '':U + chr(3) + '':U + chr(3) + v-attr-code + chr(3) + vvalue
    .
end.
v-no-hist = 0.
run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE trig-dcp :
define input parameter rs-list-method as character no-undo .
define variable v-dtm-code as integer no-undo init ?.
define variable v-dt-code as integer no-undo init ?.
define variable v-node-code as integer no-undo init ?.
define variable v-host-code as integer no-undo init 0.
define variable v-obj-type as integer no-undo init '':U.
define variable v-obj-code as integer no-undo init 0.
define variable v-cond as character no-undo .
define variable glog as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-value as character no-undo .
define variable v-label as character no-undo .
define variable v-sum-id as character no-undo .
define variable v-item as character no-undo .
define variable v-value-character-low as character no-undo .
define variable v-value-date-low as date no-undo .
define variable v-value-decimal-low as decimal no-undo .
define variable v-value-integer-low as integer no-undo .
define variable v-value-logical-low as logical no-undo .
define variable v-value-character-high as character no-undo .
define variable v-value-date-high as date no-undo .
define variable v-value-decimal-high as decimal no-undo .
define variable v-value-integer-high as integer no-undo .
define variable v-value-logical-high as logical no-undo .
define variable v-ok as logical no-undo .
run ref/dcprpsel.w (
                     input parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output v-dtm-code
                    ,input-output v-dt-code
                    ,input-output v-node-code
                    ,input-output v-host-code
                    ,input-output v-obj-type
                    ,input-output v-obj-code
                    ,input-output v-cond
                    ,output v-value-character-low
                    ,output v-value-character-high
                    ,output v-value-date-low
                    ,output v-value-date-high
                    ,output v-value-decimal-low
                    ,output v-value-decimal-high
                    ,output v-value-integer-low
                    ,output v-value-integer-high
                    ,output v-value-logical-low
                    ,output v-value-logical-high
                    ,output v-ok
                    ) no-error.
if error-status:error
or v-dtm-code = ?
or not v-ok
then undo, return error .
run discprop-node-name in this-procedure ( input (string(v-dtm-code) + chr(4) + (if v-node-code <> ? then string(v-node-code) else ''))
                                          ,output v-tool-tip
                                          ,output v-label).
if rs-list-method = "dcp" then do:
  message
  substitute("Карты, имеющие &1 &2"
             ,v-label
             ,(if v-dt-code <> ?
               then substitute(" Срез &1", v-sum-id)
               else '':U)
            )
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    return error.
  end.
  assign
  dsp-rs = substitute("Карты, имеющие &1 &2: &3"
                      , v-label
                      ,(if v-dt-code <> ?
                        then substitute(" Срез &1", v-sum-id)
                        else '':U)
                      , stat-line(rs-status))
  v-item = substitute("&2&1&3&1&4"
                      , chr(3)
                      , v-dtm-code
                      , v-dt-code
                      , v-node-code)
  .
end.
if rs-list-method = "dcp-val" then do:
  message
  substitute("Карты, имеющие &1 &2 = &3"
             ,v-label
             ,(if v-dt-code <> ?
               then substitute(" Срез &1", v-sum-id)
               else '':U)
            , v-value
            )
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    return error.
  end.
  assign
  dsp-rs = substitute("Карты, имеющие &1 &2 = &3: &4"
                      , v-label
                      ,(if v-dt-code <> ?
                        then substitute(" Срез &1", v-sum-id)
                        else '':U)
                      , v-value
                      , stat-line(rs-status))
  v-item = substitute("&2&1&3&1&4&1&5"
                      , chr(3)
                      , v-dtm-code
                      , v-dt-code
                      , v-node-code)
  .
end.
v-no-hist = 0.
run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE proc-sum-id :
define input parameter rs-list-method as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type  like ub.clients.obj-type no-undo .
define variable v-obj-code  like ub.clients.obj-code no-undo .
define variable v-dt-code    as integer no-undo .
define variable v-get-r-b as character no-undo .
define variable v-field as character no-undo .
define variable v-field-des as character no-undo .
define variable v-low as decimal no-undo .
define variable v-high as decimal no-undo .
define variable v-ok as logical no-undo .
define variable v-sum-id-type as character no-undo .
define variable v-item as character no-undo .
define variable v-cond as character no-undo init '>':U.
define variable v-last-change-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
v-sum-id-type = replace(rs-list-method, 'last-change-', '':U).
run cur-time in this-procedure ( output v-today, output v-time).
v-last-change-date = v-today - 2.
run ref/dcsumid.w (
                   input parparentproc
                  ,input this-procedure:handle
                  ,input (if rs-list-method begins "last-change" then 'last-change' else 'current-values')
                  ,input-output v-sum-id-type
                  ,input-output v-dt-code
                  ,input-output v-host-code
                  ,input-output v-obj-type
                  ,input-output v-obj-code
                  ,input-output v-get-r-b
                  ,input-output v-field
                  ,input-output v-cond
                  ,input-output v-last-change-date
                  ,output v-field-des
                  ,output v-low
                  ,output v-high
                  ,output v-ok
                  ).
if not v-ok then return error.
if rs-list-method begins 'last' then do:
  assign
  dsp-rs = substitute("&1 &2 &3 &4 &5 &6 &7 "
                      ,(if v-sum-id-type = 'general-sum-id':U
                        then 'Общие итоги по карте'
                        else 'Частные итоги по карте')
                      , (if v-sum-id-type = 'general-sum-id':U
                          then '':U
                          else dct-algo-get-description-sum-id(v-dt-code) )
                      , (if v-host-code = 0
                          then 'Глобальные'
                          else substitute('Фирма &1', v-host-code))
                        , (if v-obj-code = 0 then '':u else substitute("&1&2", v-obj-type, v-obj-code))
                        , v-field-des
                        , v-cond
                        , v-last-change-date)
  v-item = string(v-dt-code) + chr(3) +
          string(v-host-code) + chr(3) +
          v-obj-type + chr(3) +
          string(v-obj-code) + chr(3) +
          v-cond + chr(3) +
          string(v-last-change-date, "99/99/9999")
          .
end.
else do:
  assign
  dsp-rs = substitute("&1 &2 &3 &4 &5 = &6 - &7 "
                      ,(if v-sum-id-type = 'general-sum-id':U
                        then 'Общие итоги по карте'
                        else 'Частные итоги по карте')
                      , (if v-sum-id-type = 'general-sum-id':U
                          then '':U
                          else dct-algo-get-description-sum-id(v-dt-code) )
                      , (if v-host-code = 0
                          then 'Глобальные'
                          else substitute('Фирма &1', v-host-code))
                        , (if v-obj-code = 0 then '':u else substitute("&1&2", v-obj-type, v-obj-code))
                        , v-field-des
                        , v-low
                        , v-high)
  v-item = string(v-dt-code) + chr(3) +
          string(v-host-code) + chr(3) +
          v-obj-type + chr(3) +
          string(v-obj-code) + chr(3) +
          v-get-r-b + chr(3) +
          v-field + chr(3) +
          string(v-low) + chr(3) +
          string(v-high).
end.
v-no-hist = 0.
run create-dc-list-hist in this-procedure (
                                      input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE trig-filter :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
message
"Все карты выбранные в соответствии с заданным фильтром (без учета сортировки)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "dc-list":U + chr(4) + "Список дисконтных карт" + chr(4) + "no"
.
assign
tbl = 'dis-card'
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('cli-type*cli-code', 'Клиент(один)', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-pcnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('category', 'Категория', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('valid-date', 'Действ.до', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('type', 'Тип карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credit-card', 'Кредитная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'К карте', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-rubl', 'Сальдо рубли', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-base', 'Сальдо баз_вал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('main-card', 'Основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-subsid', 'Дополнительная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-card', 'Первичная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-main-card', 'Первичная основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'Перевыпущена к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('overissue-num', 'Порядок в цепочке перевыпуска', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (
                input  c-point
                ,output v-flt-rec
                ,output v-filter-name
                ,output where-phrase
                ,output sort-phrase
                ,output where-phrase-rus
                ,output sort-phrase-rus  ).
if v-flt-rec = ? then do:
  run MyENable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                      , input-output v-seq
                                      , input 0
                                      , input '':U
                                      , input substitute("Фильтр : &1 &2 &3", ubflt.filter.naim, ubflt.filter.where-ysl-rus, stat-line(rs-status))
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.
END PROCEDURE.
PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-dc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("КАРТА &1 &2&3", dc-list.d-card, dc-list.cli-type, dc-list.cli-code)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('dis-card':U + chr(3) + string(dc-list.d-card))
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-dc-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input substitute("КАРТА &1 &2&3", dc-list.d-card, dc-list.cli-type, dc-list.cli-code)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('dis-card':U + chr(3) + string(dc-list.d-card))
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-dc-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                        , input-output  v-temp-seq
                                        , input v-ii
                                        , input get-hist-mode(line-mode)
                                        , input '':U
                                        , input tot-lns
                                        , input rs-list-method
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
  end.
end.
END PROCEDURE.
FUNCTION get-num-chk RETURNS CHARACTER
  ( buffer loc-dis-card for dc-list ) :
DEFINE VARIABLE var-cli-name as character no-undo .
define buffer loc-clients for ub.clients.
FIND loc-clients WHERE
     loc-clients.obj-type = loc-dis-card.cli-type AND
     loc-clients.obj-code = loc-dis-card.cli-code NO-LOCK .
if avail loc-clients then
var-cli-name = loc-clients.obj-name .
RETURN var-cli-name.
END FUNCTION.
FUNCTION stat-line RETURNS CHARACTER
  ( input p-status-chr as character ) :
DEFINE VARIABLE var-stat-line as character no-undo .
CASE p-status-chr:
  when 'все':U then do:
    assign
    var-stat-line = "(текущие, удаленные и блокированные карты)"
    .
  end.
  when 'тек':U then do:
    assign
    var-stat-line = "(текущие карты)"
    .
  end.
  when 'удал':U then do:
    assign
    var-stat-line = "(удаленные карты)"
    .
  end.
  when 'блок':U then do:
    assign
    var-stat-line = "(блокированные карты)"
    .
  end.
END CASE.
return var-stat-line .
END FUNCTION.
