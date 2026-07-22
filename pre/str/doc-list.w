define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Автоматизированное формирование списка документов":U .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  SHARED  temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   SHARED   temp-table doc-list-hist no-undo
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
procedure create-doc-list-hist :
define input parameter p-mode as character no-undo .
define input-output parameter p-seq as integer no-undo .
define input parameter p-line as integer no-undo .
define input parameter p-list-table as character no-undo .
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
define buffer buf_doc-list-hist for doc-list-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_doc-list-hist where
                   buf_doc-list-hist.id = 0   no-error.
        if not available buf_doc-list-hist then do:
          create buf_doc-list-hist.
          assign
          buf_doc-list-hist.id = 0
          buf_doc-list-hist.line = 0
          buf_doc-list-hist.list-table = '':U
          .
        end.
        assign
        buf_doc-list-hist.des =  p-des
        buf_doc-list-hist.num-recs = p-num-recs
        buf_doc-list-hist.option_  = p-option
        buf_doc-list-hist.item_ = p-item
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
        create buf_doc-list-hist.
        assign
        buf_doc-list-hist.id = p-seq
        buf_doc-list-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_doc-list-hist.des =  p-des
        buf_doc-list-hist.line = p-line
        buf_doc-list-hist.num-recs = p-num-recs
        buf_doc-list-hist.option_  = p-option
        buf_doc-list-hist.item_ = p-item
        buf_doc-list-hist.hist-mode =  p-hist-mode
        buf_doc-list-hist.status_ =  p-status_
        buf_doc-list-hist.num-add = v-num-add
        buf_doc-list-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_doc-list-hist where
                  buf_doc-list-hist.id = p-seq
              and buf_doc-list-hist.line = p-line no-error .
        if  available buf_doc-list-hist then do:
          assign
          buf_doc-list-hist.des =  p-des
          buf_doc-list-hist.num-recs = p-num-recs
          buf_doc-list-hist.option_  = p-option
          buf_doc-list-hist.item_ = p-item
          buf_doc-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_doc-list-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_doc-list-hist where
                  buf_doc-list-hist.id = p-seq
              and buf_doc-list-hist.line = p-line  no-error .
        if available buf_doc-list-hist then do:
          assign
          buf_doc-list-hist.hist-mode =  p-hist-mode
          buf_doc-list-hist.num-recs  = (if buf_doc-list-hist.line = 0 then p-num-recs else buf_doc-list-hist.num-recs)
          buf_doc-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_doc-list-hist.list-table)
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
        buf_doc-list-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_doc-list-hist.item_ = "!ERROR"
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
DEFINE TEMP-TABLE temp-list NO-UNDO LIKE ub.units
field fname as character format "X(40)"
field fvalue as character
field id as integer
index pi is primary unique
id.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-doc-list for doc-list
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
    varshift-name = string(loc-doc-list.shift-num).
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-doc-list.obj-type,
                       input  loc-doc-list.obj-code,
                       input  loc-doc-list.shift-date,
                       input  loc-doc-list.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
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
define buffer l-doc-list for doc-list.
define variable v-sort-mode as character no-undo .
define variable v-sort as integer   no-undo .
define variable f-doc-name as char init "default.trn" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable grp-list as char no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define variable vvalue as character no-undo.
define variable vother as character no-undo.
define variable vproc-attr       as character no-undo .
define variable vfull-screen-val as character no-undo .
define variable choice as logical   no-undo init ?.
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable v-table-name as character no-undo .
define variable v-user-select as logical no-undo .
define variable vfillin_width as integer   no-undo .
define variable vfillin_height as integer   no-undo .
define variable vtype1 as character no-undo.
define variable vvalue1 as character no-undo.
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine VARiable RS-list-method AS CHARACTER.
define variable lns-ignore as integer no-undo .
define variable save-option as character no-undo.
define variable dcli-type like ub.trn-doc.cli-type no-undo.
define variable dcli-code like ub.trn-doc.cli-code no-undo.
define variable dcli-name like ub.clients.obj-name no-undo.
define variable ddoc-PS like ub.clients.obj-name no-undo.
define variable rs-status as character no-undo .
define variable line-mode as character no-undo .
define variable lns-cnt as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable line-rec as recid no-undo .
define variable vsort as integer   no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .
define new shared variable br-handle as handle no-undo.
define new shared buffer f-doc for ub.fbr-doc.
DEFINE new shared QUERY br-docs FOR f-doc SCROLLING.
define variable f-name as char init "default.trn" no-undo.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION get-table-name returns character(input p-doc-type as character):
CASE p-doc-type:
  when 'переоценка':U then return 'price-doc':U.
  when 'производство':U then return 'fbr-doc':U.
  when 'касс':U then return 'inkas':U.
  when ("-" + 'касс':U) then return 'c-inkas':U.
  otherwise do:
   if lookup(p-doc-type, 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0 then return 'ord-doc':U.
   if p-doc-type begins "-"
   and lookup(entry(2, p-doc-type), 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0 then return 'c-ord-doc':U.
   if p-doc-type begins "-" then return 'c-trn-doc':U.
   return 'trn-doc':U.
  end.
END CASE.
END FUNCTION.
FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character)  FORWARD.
DEFINE MENU MENU-B-print
       MENU-ITEM m_main-print   LABEL "Простой формат"
       MENU-ITEM m_doc-print    LABEL "Печать документов"
       MENU-ITEM m_ex-print     LABEL "По шаблону в EXCEL".
DEFINE MENU MENU-B-save
       MENU-ITEM m_doc-save     LABEL "Файл списка документов"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка"
       RULE
       MENU-ITEM m-rum           LABEL "Операции над списком" .
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 15 BY 1 TOOLTIP "Добавление в список документов 1 строки".
DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".
DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все документы (строки)".
DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 15 BY 1 TOOLTIP "Удаление из списка документов 1 строки".
DEFINE BUTTON b-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Переместить документ вниз".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".
DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего документа".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего документа".
DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".
DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 15 BY 1 TOOLTIP "Оставить в списке документов только текущую строку".
DEFINE BUTTON B-save
     LABEL "Со&хр./Выполн."
     SIZE 15 BY 1 TOOLTIP "Сохранить список документов в текстовом файле, EXCEL".
DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".
DEFINE BUTTON b-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Переместить документ вверх".
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 70 BY 1.54 NO-UNDO.
DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало №"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "Факт. дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE QUERY BR-list FOR
      doc-list SCROLLING.
DEFINE QUERY BR-option FOR
      temp-list SCROLLING.
DEFINE BROWSE BR-list
  QUERY BR-list DISPLAY
      doc-list.doc-code COLUMN-LABEL "Документ" FORMAT "X(14)":U
      doc-list.obj-type FORMAT "X(3)":U
      doc-list.obj-code FORMAT "99999":U
      doc-list.fact-date COLUMN-LABEL "Дата факт" FORMAT "99/99/9999":U
      doc-list.shift-date COLUMN-LABEL "Дата смены" FORMAT "99/99/9999":U
      shift-name-no-err(buffer doc-list) COLUMN-LABEL "№ смены" FORMAT "X(6)":U
      doc-list.doc-type COLUMN-LABEL "Тип док-та" FORMAT "X(10)":U
      get-client(input doc-list.doc-code, input doc-list.doc-type) + string(dcli-code) COLUMN-LABEL "Контрагент" FORMAT "X(12)":U
      dcli-name COLUMN-LABEL "Название контрагента" FORMAT "X(40)":U
      doc-list.sel-order COLUMN-LABEL "Пор.Номер" FORMAT ">>>,>>>,>>9":U
      doc-list.is-del COLUMN-LABEL "У" FORMAT "+/":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70 BY 16.13.
DEFINE BROWSE BR-option
  QUERY BR-option DISPLAY
      temp-list.fname format "X(30)"
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 28 BY 21 TOOLTIP "Условие для выбора документов, которые будут добавлены/удалены/оставлены".
DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 61
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-print AT ROW 2 COL 21
     B-lkp AT ROW 2 COL 41
     B-clr AT ROW 2 COL 51
     B-macro AT ROW 2 COL 61
     B-stop AT ROW 2 COL 65
     B-clear-macro AT ROW 2 COL 65
     B-record AT ROW 2 COL 65
     BR-option AT ROW 2 COL 72
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 26
     B-rest AT ROW 3 COL 41
     BR-list AT ROW 4.21 COL 1.25
     f-tot-lns AT ROW 3.5 COL 60 COLON-ALIGNED NO-LABEL
     sch-code AT ROW 20.5 COL 2.63
     sch-date AT ROW 20.5 COL 46.38 COLON-ALIGNED
     b-up AT ROW 20.5 COL 66
     b-down AT ROW 20.5 COL 71
     ED-notes AT ROW 21.54 COL 1 NO-LABEL
     SPACE(21.36) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список документов"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ASSIGN
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.
ASSIGN
       ED-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-clr IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define buffer buf-doc-list-hist for doc-list-hist.
message
"Удаление всех строк списка. Вы уверены ?"
 view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each doc-list:
  delete doc-list.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-doc-list-hist:
  delete buf-doc-list-hist.
end.
run create-doc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                     , input-output v-seq
                                     , input 0
                                     , input '':U
                                     , input '0':U
                                     , input "# Список документов очищен."
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
ON CHOOSE OF b-down IN FRAME Dialog-Frame
DO:
  define buffer buf_prev_doc-list for doc-list .
  if available doc-list
  then do:
    find first buf_prev_doc-list
      where buf_prev_doc-list.sel-order > doc-list.sel-order
      use-index sel-order
      no-error .
    if not available buf_prev_doc-list
    then do:
      message
        "Текущий документ последний в списке"
        view-as alert-box information .
    end.
    else do:
      define variable v-current-sel-order as integer   no-undo .
      assign
        v-current-sel-order    = doc-list.sel-order
        doc-list.sel-order          = buf_prev_doc-list.sel-order
        buf_prev_doc-list.sel-order = v-current-sel-order
      .
      define variable v-current-rowid as rowid no-undo .
      assign
        v-current-rowid = rowid(doc-list)
      .
      run openbr in this-procedure .
      reposition br-list to rowid v-current-rowid no-error .
    end.
  end.
  else do:
    message
      "Документ не выбран" skip
      view-as alert-box information .
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define buffer buf_doc-list-hist for doc-list-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
find first buf_doc-list-hist no-lock where buf_doc-list-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка документов "
(if available buf_doc-list-hist
then buf_doc-list-hist.des
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
for each buf_doc-list-hist where buf_doc-list-hist.id > 0
by buf_doc-list-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_doc-list-hist.line = 0
   then string(buf_doc-list-hist.id, ">>>>>>>>9")
   else fill(chr(32) , 9)
  )  chr(32)
  (if buf_doc-list-hist.item_ <> '':U
   then string(buf_doc-list-hist.hist-mode, "X(8)")
   else fill( chr(32), 8)) chr(32)
  string(buf_doc-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
  string(buf_doc-list-hist.num-recs, ">>>>>>>>9")  chr(32)
  string(buf_doc-list-hist.des, "X(155)") skip.
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
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-host-code as integer no-undo .
define variable v-fbr-doc-next-prev as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc for ub.ord-doc.
 if not available doc-list then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
 end.
 CASE doc-list.doc-type:
   when 'производство':U then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  doc-list.obj-type
  ,input  doc-list.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_lookup':U
    ,input  'object':U
    ,input  v-host-code
    ,input  doc-list.obj-type
    ,input  doc-list.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if not glog then   return no-apply.
    v-fbr-doc-next-prev = yes.
    find first f-doc no-lock where
              f-doc.doc-code = doc-list.doc-code no-error.
    if not available f-doc then do:
      message
      substitute("Документ производства &1 уже недоступен", doc-list.doc-code)
      view-as alert-box error .
      return no-apply.
    end.
    assign
    v-doc-rec = recid (f-doc)
    .
    run str/fbr-doc.w (
        input parparentproc
      , input this-procedure
      , input 'ПРОСМОТР':U
      , input v-doc-rec
      , output v-doc-rec
      , input-output v-fbr-doc-next-prev
    ).
   end.
   when 'переоценка':U then do:
     run str/showdoc.p
                (input parparentproc,
                input doc-list.doc-code,
                input "",
                input "",
                input 0,
                false
                ).
    end.
    when 'касс':U then do:
        find first buf_inkas no-lock where
                  buf_inkas.inkas-code = doc-list.doc-code no-error .
        v-doc-rec = recid(buf_inkas).
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_lookup':U
    ,input  'object':U
    ,input  buf_inkas.host-code
    ,input  buf_inkas.obj-type
    ,input  buf_inkas.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
        if NOT glog then return no-apply.
        run str/ink-lkp.p (input parparentproc
                    , input v-doc-rec).
    end.
    when ("-" + 'касс':U) then do:
      message
      "Просмотр удаленной продажи невозможен"
      view-as alert-box error .
    end.
    otherwise do:
      if lookup(doc-list.doc-type, 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0 then do:
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = doc-list.doc-code no-error .
        v-doc-rec = recid(buf_ord-doc).
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_lookup':U
    ,input  'object':U
    ,input  buf_ord-doc.host-code
    ,input  buf_ord-doc.obj-type
    ,input  buf_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
        if NOT glog then return no-apply.
        run cus/show-ord.p ( input parParentProc
                            ,input v-doc-rec) .
      end.
      else do:
        if doc-list.doc-type begins "-" then do:
          find first buf_c-trn-doc no-lock where
                    buf_c-trn-doc.doc-code = doc-list.doc-code
              and  buf_c-trn-doc.is-del = yes no-error.
          if available buf_c-trn-doc then do:
            run str/c-doc.w ( input parparentproc
                            , input buf_c-trn-doc.doc-code
                            , input buf_c-trn-doc.chip-num ).
          end.
          else do:
            message
            substitute("Не удалось найти удаленный документ &1", doc-list.doc-code)
            view-as alert-box error .
          end.
        end.
      run str/showdoc.p
                  (input parparentproc,
                  input doc-list.doc-code,
                  input "",
                  input "",
                  input 0,
                  true
                  ).
    end.
   end.
 END CASE.
 apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
    if save-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   run proc-b-save in this-procedure (save-option) no-error.
   if error-status:error then return no-apply.
END.
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:
  define buffer buf_prev_doc-list for doc-list .
  if available doc-list
  then do:
    find last buf_prev_doc-list
      where buf_prev_doc-list.sel-order < doc-list.sel-order
      use-index sel-order
      no-error .
    if not available buf_prev_doc-list
    then do:
      message
        "Текущий документ первый в списке"
        view-as alert-box information .
    end.
    else do:
      define variable v-current-sel-order as integer   no-undo .
      assign
        v-current-sel-order    = doc-list.sel-order
        doc-list.sel-order          = buf_prev_doc-list.sel-order
        buf_prev_doc-list.sel-order = v-current-sel-order
      .
      define variable v-current-rowid as rowid no-undo .
      assign
        v-current-rowid = rowid(doc-list)
      .
      run openbr in this-procedure .
      reposition br-list to rowid v-current-rowid no-error .
    end.
  end.
  else do:
    message
      "Документ не выбран" skip
      view-as alert-box information .
  end.
END.
ON VALUE-CHANGED OF BR-list IN FRAME Dialog-Frame
DO:
  if avail doc-list then do:     assign ed-notes = ddoc-ps.     display     ed-notes     tot-lns @ f-tot-lns     with frame Dialog-Frame.   end.    else do:     assign ed-notes = ''.     display ed-notes      tot-lns @ f-tot-lns     with frame Dialog-Frame.   end.
END.
ON VALUE-CHANGED OF BR-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_doc-print
DO:
  run proc-doc-print in this-procedure .
  choice = ?.
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_doc-save
DO:
  assign
  save-option = "doc-list":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_ex-print
DO:
  run proc-ex-print in this-procedure .
  choice = ?.
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-macros-save  DO:
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF MENU-ITEM m_main-print
DO:
  define variable v-frame-width as integer no-undo.
  run str/docl-prn.p (input parparentproc,
                input p-curr-host-code,
                input p-curr-obj-type,
                input p-curr-obj-code,
                input "",
                output v-Frame-Width) no-error.
  if v-frame-width <= 198 then do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input (if v-frame-width <= 136 then 0 else 8)
                                              ).
  end.
  else do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input (if v-frame-width <= 255 then 1 else 20)
                                              ).
  end.
  choice = ?.
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-rum  DO:
define variable glog as logical no-undo .
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input 'edoc':U + chr(4) +
            ('batchwork-routing_order':U + chr(44) +
             'batchwork-routing_price-doc':U + chr(44) +
             'batchwork-routing_trn-doc':U +  chr(44) +
             'batchwork-routing_inkas':U
            )
    , input no
    , input "&Стоп"
    , input substitute("Операции на списком документов") ) .
END.
ON CHOOSE OF MENU-ITEM m-title-save
DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ДОКУМЕНТОВ" + '\':u
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
run create-doc-list-hist in this-procedure (input 'title'
                                     , input-output v-seq
                                     , input 0
                                     , input '':U
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
frame Dialog-Frame:title = substitute("СПИСОК ДОКУМЕНТОВ &1", v-value).
END.
ON CHOOSE OF MENU-ITEM m_xls-save
DO:
    assign
  save-option = "excel":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  assign
  sch-code.
  run proc-find in this-procedure ("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  assign
  sch-code.
  run proc-find in this-procedure ("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
   assign
  sch-date.
  run proc-find in this-procedure ("fact-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
   assign
  sch-date.
  run proc-find in this-procedure ("fact-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
on any-printable of br-list in frame Dialog-Frame do:
  apply "entry" to sch-code in frame Dialog-Frame.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dialog-Frame DO:
    apply "choose" to b-lkp in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-doc :
DEFINE INPUT PARAMETER loc-is-trn-doc as integer no-undo.
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    CASE loc-is-trn-doc:
      when 1 then do:
        if ub.trn-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.trn-doc.doc-code
             and  doc-list.doc-type = ub.trn-doc.doc-type
                  no-error.
      end.
      when 101 then do:
        if ub.c-trn-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.c-trn-doc.doc-code
             and  doc-list.doc-type = "-" + ub.c-trn-doc.doc-type
                  no-error.
      end.
      when 0 then do:
        if ub.price-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.price-doc.doc-num
             and  doc-list.doc-type = 'переоценка':U
                  no-error.
      end.
      when 2 then do:
        if ub.inkas.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.inkas.inkas-code
             and  doc-list.doc-type = 'касс':U
                  no-error.
      end.
      when 102 then do:
        if ub.c-inkas.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.c-inkas.inkas-code
             and  doc-list.doc-type = "-" + 'касс':U
                  no-error.
      end.
      when 3 then do:
        if ub.fbr-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.fbr-doc.doc-code
             and  doc-list.doc-type = 'производство':U
                  no-error.
      end.
      when 4 then do:
        message
        ub.ord-doc.host-code <> p-curr-host-code
        view-as alert-box .
        if ub.ord-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.ord-doc.doc-code
             and  doc-list.doc-type = ub.ord-doc.doc-type
                  no-error.
      end.
    end CASE.
    if available doc-list then do:
      if line-mode = 'удаление':U then do:
         lns-cnt = lns-cnt + 1.
         delete doc-list.
      end.
      if line-mode = 'ОСТАВИТЬ':U then do:
        if doc-list.to-del = ? then .
        else do:
          lns-cnt = lns-cnt + 1.
          doc-list.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U
    then do:
      define variable v-sel-order as integer   no-undo .
      define buffer buf_sel_order_doc-list for doc-list .
      find last buf_sel_order_doc-list
        use-index sel-order
        no-error .
      if available buf_sel_order_doc-list
      then do:
        assign
          v-sel-order = buf_sel_order_doc-list.sel-order + 1
        .
      end.
      else do:
        assign
          v-sel-order = 1
        .
      end.
      CASE loc-is-trn-doc:
        when 1 then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.trn-doc.doc-code
    and doc-list.doc-type = ub.trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.trn-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.trn-doc.doc-code
  doc-list.obj-type   = ub.trn-doc.obj-type
  doc-list.obj-code   = ub.trn-doc.obj-code
  doc-list.fact-num   = ub.trn-doc.fact-num
  doc-list.doc-date   = ub.trn-doc.doc-date
  doc-list.fact-date  = ub.trn-doc.fact-date
  doc-list.shift-date = ub.trn-doc.shift-date
  doc-list.shift-num  = ub.trn-doc.shift-num
  doc-list.fact-order = ub.trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = ub.trn-doc.doc-type
  doc-list.ext-doc-type   = ub.trn-doc.ext-doc-type
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 101 then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.c-trn-doc.doc-code
    and doc-list.doc-type = "-" + ub.c-trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.c-trn-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.c-trn-doc.doc-code
  doc-list.obj-type   = ub.c-trn-doc.obj-type
  doc-list.obj-code   = ub.c-trn-doc.obj-code
  doc-list.fact-num   = ub.c-trn-doc.fact-num
  doc-list.doc-date   = ub.c-trn-doc.doc-date
  doc-list.fact-date  = ub.c-trn-doc.fact-date
  doc-list.shift-date = ub.c-trn-doc.shift-date
  doc-list.shift-num  = ub.c-trn-doc.shift-num
  doc-list.fact-order = ub.c-trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.doc-type   = "-" + ub.c-trn-doc.doc-type
  doc-list.ext-doc-type   = ub.c-trn-doc.ext-doc-type
  doc-list.is-del     = yes
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 0 then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.price-doc.doc-num
    and doc-list.doc-type = 'переоценка':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.price-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.price-doc.doc-num
  doc-list.obj-type   = ub.price-doc.obj-type
  doc-list.obj-code   = ub.price-doc.obj-code
  doc-list.fact-num   = ub.price-doc.fact-num
  doc-list.fact-date  = ub.price-doc.fact-date
  doc-list.shift-date = ub.price-doc.shift-date
  doc-list.shift-num  = ub.price-doc.shift-num
  doc-list.fact-order = ub.price-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'переоценка':U
  doc-list.ext-doc-type   = 'ot':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 2 then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.inkas.inkas-code
  and doc-list.doc-type = 'касс':U
  no-error .
find first inkas_trn-doc where
           inkas_trn-doc.doc-code = ub.inkas.inkas-code no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.inkas.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.inkas.inkas-code
  doc-list.obj-type   = ub.inkas.obj-type
  doc-list.obj-code   = ub.inkas.obj-code
  doc-list.fact-num   = inkas_trn-doc.fact-num
  doc-list.fact-date  = ub.inkas.fact-date
  doc-list.shift-date = ub.inkas.shift-date
  doc-list.shift-num  = ub.inkas.shift-num
  doc-list.fact-order = inkas_trn-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'касс':U
  doc-list.ext-doc-type   = 'касс':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 102 then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.c-inkas.inkas-code
  and doc-list.doc-type = "-" + 'касс':U
  no-error .
find first c-inkas_trn-doc where
           c-inkas_trn-doc.doc-code = ub.c-inkas.inkas-code
     and  c-inkas_trn-doc.is-del = yes  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.c-inkas.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.c-inkas.inkas-code
  doc-list.obj-type   = ub.c-inkas.obj-type
  doc-list.obj-code   = ub.c-inkas.obj-code
  doc-list.fact-num   = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-num else 0)
  doc-list.fact-date  = ub.c-inkas.fact-date
  doc-list.shift-date = ub.c-inkas.shift-date
  doc-list.shift-num  = ub.c-inkas.shift-num
  doc-list.fact-order = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-order else ?)
  doc-list.is-trn-doc = no
  doc-list.is-del     = yes
  doc-list.doc-type   =   "-" + 'касс':U
  doc-list.ext-doc-type = 'касс':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 3 then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.fbr-doc.doc-code
    and doc-list.doc-type = 'производство':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.fbr-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.fbr-doc.doc-code
  doc-list.obj-type   = ub.fbr-doc.obj-type
  doc-list.obj-code   = ub.fbr-doc.obj-code
  doc-list.fact-num   = 0
  doc-list.fact-date  = ub.fbr-doc.fact-date
  doc-list.shift-date = ub.fbr-doc.shift-date
  doc-list.shift-num  = ub.fbr-doc.shift-num
  doc-list.fact-order = 0
  doc-list.is-trn-doc = no
  doc-list.doc-type   = 'производство':U
  doc-list.ext-doc-type   = 'производство':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 4 then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.ord-doc.doc-code
  and doc-list.doc-type = ub.ord-doc.doc-type no-error.
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.ord-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.ord-doc.doc-code
  doc-list.obj-type   = ub.ord-doc.obj-type
  doc-list.obj-code   = ub.ord-doc.obj-code
  doc-list.fact-num   = ub.ord-doc.fact-num
  doc-list.fact-date  = ub.ord-doc.fact-date
  doc-list.shift-date = ub.ord-doc.shift-date
  doc-list.shift-num  = ub.ord-doc.shift-num
  doc-list.fact-order = ub.ord-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = ub.ord-doc.doc-type
  doc-list.ext-doc-type   = ub.ord-doc.doc-type
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
      END CASE.
    end.
  if lns-cnt modulo 25 = 0 then
  display
   "Ждите..." + string (lns-cnt) @ dsp-rs
   with frame Dialog-Frame.
end PROCEDURE.
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
define variable p-title as character no-undo .
define variable bttns as character no-undo .
define variable p-keep-query as logical no-undo .
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
define buffer buf-doc-list-hist for doc-list-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each doc-list:
      delete doc-list.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-doc-list-hist:
      delete buf-doc-list-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-doc-list-hist in this-procedure (
                                          input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
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
                                  ,input  ?
                                  ,input rs-status)  no-error .
  if error-status:error then return no-apply.
end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
or DELETE-CHARACTER of br-list
DO:
  if not available doc-list then return no-apply.
  assign rs-list-method = "single".
    run proc-b-del in this-procedure(
                                               input no
                                              ,input ?
                                              ,input rs-list-method
                                              ,input ?
                                              ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-rest IN FRAME Dialog-Frame
DO:
if not available doc-list then return no-apply.
  assign rs-list-method = "single".
 run proc-b-rest in this-procedure(
                                                input no
                                               ,input ?
                                               ,input rs-list-method
                                               ,input  ?
                                               ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-macro IN FRAME Dialog-Frame
DO:
run proc-b-macro in this-procedure ( input 'file') no-error .
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
disable
b-record with frame Dialog-Frame .
hide
b-record
b-macro
in frame Dialog-Frame .
enable
b-stop with frame Dialog-Frame .
run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
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
define buffer buf_doc-list-hist for doc-list-hist.
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
run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
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
for each buf_doc-list-hist where
        buf_doc-list-hist.id >=  an-listp-start-macro-id
  and  buf_doc-list-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_doc-list-hist
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
      v-num-entries-options = num-entries("Текущая строка,single,                       Накладная,trn-doc,                            Накладные с <=датой ФАКТ<=,trn-doc-fact-date,   Переоценка,price-doc,                         Переоценки с <=датой ФАКТ<=,price-doc-fact-date,       Продажи,inkas,                                Продажи c <=датой ФАКТ<=,inkas-fact-date,    Производство,fbr-doc,                         Заказ/заявка,ord-doc,                         Заказы/заявки с <=датой ФАКТ<=,ord-doc-fact-date,   УДАЛЕННАЯ накладная,c-trn-doc,                            УДАЛЕННЫЕ накладные с <=датой ФАКТ<=,c-trn-doc-fact-date,   УДАЛЕННЫЕ Продажи,c-inkas,                                УДАЛЕННЫЕ Продажи c <=датой ФАКТ<=,c-inkas-fact-date,    С установл.атрибутом,attr,                    С атрибутом= ,attr-val,                       Накладные  контр-та,cli-trn-doc,              Накладные гр-пы контр-тов,cli-grp-trn-doc,    Накладные сп-ка контр-тов,cli-list-trn-doc,   Накл. с тов. из списка,trn-gds-list,          Переоц. с тов. из списка,price-gds-list,      Файл,file,                                    Фильтр переоценок,filter-price,               Фильтр накладных,filter-trn,                  Фильтр производств,filter-fbr,                Фильтр продаж,filter-inkas")
    .
    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,"Текущая строка,single,                       Накладная,trn-doc,                            Накладные с <=датой ФАКТ<=,trn-doc-fact-date,   Переоценка,price-doc,                         Переоценки с <=датой ФАКТ<=,price-doc-fact-date,       Продажи,inkas,                                Продажи c <=датой ФАКТ<=,inkas-fact-date,    Производство,fbr-doc,                         Заказ/заявка,ord-doc,                         Заказы/заявки с <=датой ФАКТ<=,ord-doc-fact-date,   УДАЛЕННАЯ накладная,c-trn-doc,                            УДАЛЕННЫЕ накладные с <=датой ФАКТ<=,c-trn-doc-fact-date,   УДАЛЕННЫЕ Продажи,c-inkas,                                УДАЛЕННЫЕ Продажи c <=датой ФАКТ<=,c-inkas-fact-date,    С установл.атрибутом,attr,                    С атрибутом= ,attr-val,                       Накладные  контр-та,cli-trn-doc,              Накладные гр-пы контр-тов,cli-grp-trn-doc,    Накладные сп-ка контр-тов,cli-list-trn-doc,   Накл. с тов. из списка,trn-gds-list,          Переоц. с тов. из списка,price-gds-list,      Файл,file,                                    Фильтр переоценок,filter-price,               Фильтр накладных,filter-trn,                  Фильтр производств,filter-fbr,                Фильтр продаж,filter-inkas"
                                     )
                               ,chr(32)
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,"Текущая строка,single,                       Накладная,trn-doc,                            Накладные с <=датой ФАКТ<=,trn-doc-fact-date,   Переоценка,price-doc,                         Переоценки с <=датой ФАКТ<=,price-doc-fact-date,       Продажи,inkas,                                Продажи c <=датой ФАКТ<=,inkas-fact-date,    Производство,fbr-doc,                         Заказ/заявка,ord-doc,                         Заказы/заявки с <=датой ФАКТ<=,ord-doc-fact-date,   УДАЛЕННАЯ накладная,c-trn-doc,                            УДАЛЕННЫЕ накладные с <=датой ФАКТ<=,c-trn-doc-fact-date,   УДАЛЕННЫЕ Продажи,c-inkas,                                УДАЛЕННЫЕ Продажи c <=датой ФАКТ<=,c-inkas-fact-date,    С установл.атрибутом,attr,                    С атрибутом= ,attr-val,                       Накладные  контр-та,cli-trn-doc,              Накладные гр-пы контр-тов,cli-grp-trn-doc,    Накладные сп-ка контр-тов,cli-list-trn-doc,   Накл. с тов. из списка,trn-gds-list,          Переоц. с тов. из списка,price-gds-list,      Файл,file,                                    Фильтр переоценок,filter-price,               Фильтр накладных,filter-trn,                  Фильтр производств,filter-fbr,                Фильтр продаж,filter-inkas"
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
define buffer buf_doc-list-hist for doc-list-hist.
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
        for each buf_doc-list-hist where
                buf_doc-list-hist.id >=  an-listp-start-macro-id
          and  buf_doc-list-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_doc-list-hist
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
        filters "Макрос формирования списка *.trm" "*.trm"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "trm".
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
                              ,input 'doc-list'
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
    run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                    , input '':U
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
               ,input "Макрос формирования списка документов" + chr(4) + "trm"
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
    run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
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
define  buffer buf_doc-list-hist for doc-list-hist.
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
        for each doc-list:
          delete doc-list.
        end.
        for each doc-list-hist where doc-list-hist.id > an-listp-macros-label-id:
          delete doc-list-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_doc-list-hist.
        buffer-copy macro-list-hist
        to buf_doc-list-hist
        assign buf_doc-list-hist.id = v-seq
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
                                              ,input macro-list-hist.list-table
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '-':U then do:
              run proc-b-del in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
                                              ,input macro-list-hist.list-table
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '*':U then do:
              run proc-b-rest in this-procedure(input yes
                                               ,input v-rowid
                                               ,input macro-list-hist.option_
                                               ,input macro-list-hist.list-table
                                               ,input macro-list-hist.status_) no-error .
            end.
          END.
          if error-status:error then do:
              return ("error" + chr(4) + return-value) .
          end.
          find first  buf_doc-list-hist where
                  buf_doc-list-hist.id = v-seq - 1 no-error .
          if available buf_doc-list-hist then
          assign
          macro-list-hist.num-recs = buf_doc-list-hist.num-recs
          macro-list-hist.num-add = buf_doc-list-hist.num-add
          macro-list-hist.num-ignored = buf_doc-list-hist.num-ignored
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
              create buf_doc-list-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_doc-list-hist
              assign
              buf_doc-list-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
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
                                      , input macro-list-hist.list-table
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
            for each buf_doc-list-hist where
                    buf_doc-list-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_doc-list-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_doc-list-hist.num-recs
               buf_macro-list-hist.num-add = buf_doc-list-hist.num-add
               buf_macro-list-hist.num-ignored = buf_doc-list-hist.num-ignored
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
    for each doc-list:
      if doc-list.to-del = ? then do:
        assign
        doc-list.to-del = no
        .
      end.
      else do:
        delete doc-list.
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
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-list :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBR-list as INT EXTENT 10 no-undo.
DEF VAR varmviBR-list       as INT no-undo.
DEF VAR varmvjBR-list       as INT no-undo.
DEF VAR varmvkBR-list       as INT no-undo.
DEF VAR varmvlBR-list       as INT no-undo.
DEF VAR move-elementBR-list as INT no-undo.
def var jjBR-list           as int no-undo.
do varmviBR-list = 1 to EXTENT(cur-clmn-numBR-list):
  ASSIGN cur-clmn-numBR-list[varmviBR-list] = varmviBR-list.
END.
RUN start-mv-clmnBR-list.
PROCEDURE start-mv-clmnBR-list:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BR-list do:
  RUN re-move-clmnBR-list ( 1, 10).
END.
ON ctrl-cursor-left OF BROWSE BR-list do:
  RUN re-move-clmnBR-list (10, 1).
END.
PROCEDURE re-move-clmnBR-list:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBR-list = 1 TO EXTENT(cur-clmn-numBR-list):
    if cur-clmn-numBR-list[varmviBR-list] = source-column THEN cur-clmn-numBR-list[varmviBR-list] = -1.
  END.
  if BR-list:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBR-list = source-column - 1 to target-column BY -1:
    DO varmviBR-list = 1 TO EXTENT(cur-clmn-numBR-list):
        if cur-clmn-numBR-list[varmviBR-list] = varmvjBR-list THEN DO:
          cur-clmn-numBR-list[varmviBR-list] = cur-clmn-numBR-list[varmviBR-list] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBR-list = source-column + 1 to target-column:
    DO varmviBR-list = 1 TO EXTENT(cur-clmn-numBR-list):
      if cur-clmn-numBR-list[varmviBR-list] = varmvjBR-list THEN DO:
        cur-clmn-numBR-list[varmviBR-list] = cur-clmn-numBR-list[varmviBR-list] - 1.
      END.
    END.
  END.
  DO varmviBR-list = 1 TO EXTENT(cur-clmn-numBR-list):
    if cur-clmn-numBR-list[varmviBR-list] = -1 THEN cur-clmn-numBR-list[varmviBR-list] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBR-list:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmviBR-list = 1 TO EXTENT(cur-clmn-numBR-list):
    if cur-clmn-numBR-list[varmviBR-list] = cur-clmn-loc THEN move-elementBR-list = varmviBR-list.
  END.
  RUN re-move-clmnBR-list (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultBR-list:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBR-list = 1 to EXTENT(cur-clmn-numBR-list):
    RUN re-move-clmnBR-list (cur-clmn-numBR-list[varmvlBR-list], varmvlBR-list).
  END.
  RUN start-mv-clmnBR-list.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-sort-mode = 'sort-doc-code'
  .
  run proc-fill-temp-list in this-procedure .
  ASSIGN
  b-save:MENU-MOUSE = 1
  b-print:MENU-MOUSE = 1
  .
  RUN Myenable in this-procedure .
  if v-sort-mode <> 'sort-sel-order'
  then do:
    assign
      b-up :visible   = false
      b-down :visible = false
    .
  end.
  else do:
    assign
      b-up :visible     = true
      b-down :visible   = true
      b-up :sensitive   = true
      b-down :sensitive = true
    .
    run re-move-clmnbr-list in this-procedure (input 10, 1) .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure cb_get-next-doc-by-doc-code :
define input parameter p-doc-code as character no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_doc-list for doc-list.
find first buf_doc-list no-lock where
          buf_doc-list.doc-code = p-doc-code
     and  buf_doc-list.doc-type = p-doc-type no-error.
find next buf_doc-list use-index xpk no-error.
if available buf_doc-list then do:
  p-bh:buffer-create().
  p-bh:buffer-copy(buffer buf_doc-list:handle).
end.
else do:
end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY dsp-rs sch-code sch-date ED-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs BR-option B-exit B-save B-print B-hist B-lkp B-clr B-Help B-add
         B-del B-rest B-macro B-stop B-clear-macro B-record  BR-list sch-code ~
         sch-date b-up b-down ED-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run openbr in this-procedure .    open query br-option for each temp-list no-lock .
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-start as logical no-undo .
define variable v-recid0 as recid no-undo.
define buffer buf_temp-list for temp-list.
define buffer buf_doc-list-hist for doc-list-hist.
ASSIGN b-print:MENU-MOUSE IN FRAME Dialog-Frame = 1.
ASSIGN b-save:MENU-MOUSE IN FRAME Dialog-Frame = 1.
find first buf_doc-list-hist where buf_doc-list-hist.id = 0 no-error.
if available buf_doc-list-hist then
assign
frame Dialog-Frame:title = substitute("СПИСОК  ДОКУМЕНТОВ &1",  string(buf_doc-list-hist.des, "X(60)"))
.
br-option:column-scrolling in frame Dialog-Frame  = no.
if tot-lns = ? then do:
  v-start = yes.
  for each l-doc-list :
    accumulate l-doc-list.obj-code (count).
  end.
  tot-lns = (accum count l-doc-list.obj-code).
  if tot-lns > 0 then do:
    find last  buf_doc-list-hist no-error .
    v-seq = (if available buf_doc-list-hist then buf_doc-list-hist.id else 0)  + 1.
    run create-doc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
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
    for each buf_doc-list-hist:
      delete buf_doc-list-hist.
    end.
    v-seq = 1.
    run create-doc-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input "# Исходный список документов пуст."
                                          , input tot-lns
                                          , input 'start':U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
end.
find first buf_temp-list no-lock where
            buf_temp-list.fvalue = "single".
assign
v-recid0 = recid(buf_temp-list).
open query br-option for each temp-list no-lock .
assign
RS-list-method = "single".
if v-seq > 1 then
find last buf_doc-list-hist no-lock where
          buf_doc-list-hist.id = (v-seq - 1)
      and  buf_doc-list-hist.line = 0 no-error .
DISPLAY br-option
(if available buf_doc-list-hist
then buf_doc-list-hist.des
else '') @ dsp-rs
WITH FRAME Dialog-Frame.
ENABLE
b-macro  when v-start
b-record when v-start
b-exit b-add b-hist b-help br-option br-list WITH FRAME Dialog-Frame.
if v-start then do:
  hide
  b-stop
  b-clear-macro
  in frame Dialog-Frame.
end.
v-start = no.
hide sch-code in frame Dialog-Frame
sch-date in frame Dialog-Frame
.
ENABLE
b-exit
b-add
b-hist
b-help
br-list
br-option
WITH FRAME Dialog-Frame.
reposition br-option to recid v-recid0.
if tot-lns > 0 then
  ENABLE
  b-print
  b-rest
  b-save
  b-del
  b-lkp
  b-clr
  sch-code sch-date
  WITH FRAME Dialog-Frame.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr sch-code sch-date WITH FRAME Dialog-Frame.
end.
if tot-lns = ? or tot-lns = 0 then do:
  hide sch-code sch-date in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame.
run openbr in this-procedure .
if line-rec <> ? then
  reposition br-list to recid line-rec no-error.
if avail doc-list then do:     assign ed-notes = ddoc-ps.     display     ed-notes     tot-lns @ f-tot-lns     with frame Dialog-Frame.   end.    else do:     assign ed-notes = ''.     display ed-notes      tot-lns @ f-tot-lns     with frame Dialog-Frame.   end.
END PROCEDURE.
PROCEDURE OpenBr :
  case v-sort-mode :
    when 'sort-doc-code':u
    then do:
      Open query br-list
        for each doc-list No-LOCK
        by doc-list.doc-code
        indexed-reposition
        .
    end.
    when 'sort-sel-order':u
    then do:
      Open query br-list
        for each doc-list No-LOCK
        by doc-list.sel-order
        indexed-reposition
        .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный порядок сортировки" v-sort-mode skip
        view-as alert-box error .
      Open query br-list
        for each doc-list No-LOCK indexed-reposition
        .
    end.
  end case .
  APPLY "ENTRY" to br-list in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
line-mode = 'ДОБАВЛЕНИЕ':U.
if rs-list-method = "single"
then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when 'trn-doc':U then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
      end.
      when 'c-trn-doc':U then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
      end.
      when 'price-doc':U then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
      end.
      when 'fbr-doc':U then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производство".
        end.
      end.
      when 'inkas':U then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
      end.
      when 'ord-doc':U then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
      end.
      when 'c-inkas':U then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
      end.
    END CASE.
  end.
  else do:
  define variable v-input-output as character no-undo .
  p-table-name = 'trn-doc':U.
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
                     ,input 'b-sel':U
                     ,input '':U
                     ,input ?
                     ,input ?
                     ,output ref-list
                     ) no-error .
  apply "entry" to br-list in frame Dialog-Frame.
  if ref-list = "" then   return error.
  find first ub.trn-doc where recid ( ub.trn-doc) = integer (ref-list) no-lock no-error.
  end.
  if not p-from-macro and avail ub.trn-doc
  or (
      (p-from-macro and p-table-name = 'trn-doc':U and available ub.trn-doc)
      or
      (p-from-macro and p-table-name = 'inkas':U and available ub.inkas)
      or
      (p-from-macro and p-table-name = 'price-doc':U and available ub.price-doc)
      or
      (p-from-macro and p-table-name = 'fbr-doc':U and available ub.fbr-doc)
      or
      (p-from-macro and p-table-name = 'ord-doc':U and available ub.ord-doc)
      or
      (p-from-macro and p-table-name = 'c-trn-doc':U and available ub.c-trn-doc)
      or
      (p-from-macro and p-table-name = 'c-inkas':U and available ub.c-inkas)
      )
  then do:
    run ex-doc in this-procedure (input (if not p-from-macro
                                         then 1
                                         else (if p-table-name begins "c-"
                                               then  (lookup(p-table-name, 'c-price-doc':U + chr(44) +
                                                                          'c-trn-doc':U + chr(44) +
                                                                          'c-inkas':U + chr(44) +
                                                                          'c-fbr-doc':U + chr(44) +
                                                                          'c-ord-doc':U ) - 1 + 100)
                                               else  (lookup(p-table-name, 'price-doc':U + chr(44) +
                                                                          'trn-doc':U + chr(44) +
                                                                          'inkas':U + chr(44) +
                                                                          'fbr-doc':U + chr(44) +
                                                                          'ord-doc':U ) - 1)
                                               )
                                        )
                                , input rs-list-method
                                , input rs-status
                                , input line-mode) .
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input rs-status, input line-mode).
  end.
  else do:
    return error "Нет в БД такого документа".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .
define variable glog as logical no-undo .
line-mode = 'удаление':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when 'trn-doc':U then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
        find first doc-list where doc-list.doc-code = ub.trn-doc.doc-code no-error.
      end.
      when 'c-trn-doc':U then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
        find first doc-list where doc-list.doc-code = ub.c-trn-doc.doc-code no-error.
      end.
      when 'price-doc':U then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
        find first doc-list where doc-list.doc-code = ub.price-doc.doc-num no-error.
      end.
      when 'inkas':U then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
        find first doc-list where doc-list.doc-code = ub.inkas.inkas-code no-error.
      end.
      when 'c-inkas':U then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
        find first doc-list where doc-list.doc-code = ub.c-inkas.inkas-code no-error.
      end.
      when 'fbr-doc':U then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производства".
        end.
        find first doc-list where doc-list.doc-code = price-doc.doc-num no-error.
      end.
      when 'ord-doc':U then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
        find first doc-list where doc-list.doc-code = ub.ord-doc.doc-code no-error.
      end.
    END CASE.
  end.
  if available doc-list then do:
    if not p-from-macro then p-table-name = get-table-name(input doc-list.doc-type).
    line-rec = recid (doc-list).
    get next br-list.
    if available doc-list then v-rep-rec = recid (doc-list).
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available doc-list then v-rep-rec = recid (doc-list).
    end.
    reposition br-list to recid line-rec no-error.
    tot-lns = tot-lns - 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input RS-STATUS, input line-mode).
    delete doc-list.
    line-rec = v-rep-rec.
    run Myenable in this-procedure .
  end.
  else do:
    return error "Нет в списке документов такого документа".
  end.
end.
else do:
  glog = no.
  message "Удалить документы из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
  if not glog then
    return error.
  run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define variable glog as logical no-undo .
define buffer buf_doc-list-hist for doc-list-hist.
line-mode = 'ОСТАВИТЬ':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when 'trn-doc':U then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
        find first doc-list where doc-list.doc-code = ub.trn-doc.doc-code no-error.
      end.
      when 'c-trn-doc':U then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
        find first doc-list where doc-list.doc-code = ub.c-trn-doc.doc-code no-error.
      end.
      when 'price-doc':U then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
        find first doc-list where doc-list.doc-code = ub.price-doc.doc-num no-error.
      end.
      when 'inkas':U then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
        find first doc-list where doc-list.doc-code = ub.inkas.inkas-code no-error.
      end.
      when 'c-inkas':U then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
        find first doc-list where doc-list.doc-code = ub.c-inkas.inkas-code no-error.
      end.
      when 'fbr-doc':U then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производвства".
        end.
        find first doc-list where doc-list.doc-code = ub.fbr-doc.doc-code no-error.
      end.
      when 'ord-doc':U then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
        find first doc-list where doc-list.doc-code = ub.ord-doc.doc-code no-error.
      end.
    END CASE.
  end.
  if available doc-list then do:
    if not p-from-macro then p-table-name = get-table-name(input doc-list.doc-type).
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message
      "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return error.
    end.
    line-rec = recid (doc-list).
    v-seq = 1.
    for each buf_doc-list-hist:
      delete buf_doc-list-hist.
    end.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input rs-status, input line-mode).
    for each doc-list:
      if line-rec <> recid (doc-list) then delete doc-list.
    end.
    tot-lns = 1.
    run Myenable in this-procedure .
  end.
  else do:
    return error substitute("Нет в списке такого документа").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message
    "Оставить документы в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
  for each doc-list:
    if doc-list.to-del = ? then do:
      assign
      doc-list.to-del = no
      .
    end.
    else do:
      delete doc-list.
    end.
  end.
  tot-lns = lns-cnt.
  run Myenable in this-procedure .
  message
  "Оставлено строк :" lns-cnt skip(0)
  string(if lns-ignore <> 0
  then ("Проигнорировано строк :" + string(lns-ignore))
  else "":U)
  .
end.
END PROCEDURE.
PROCEDURE proc-b-save :
define input parameter loc-save-option as character no-undo.
define variable v-frame-width as integer no-undo.
define variable glog as logical no-undo .
case loc-save-option:
    when "doc-list":U then do:
      assign
      f-doc-name = "default.trn"
      glog = yes
      .
      system-dialog get-file f-doc-name
      filters "Списки документов *.trn" "*.trn"
      ask-overwrite
      save-as
      use-filename
      update glog
      default-extension "trn".
      if not glog then do:
        apply "entry" to br-list in frame Dialog-Frame.
        return no-apply.
      end.
      output to value (f-doc-name).
      for each doc-list:
        export
        doc-list.doc-code
        doc-list.doc-type
        doc-list.obj-type
        doc-list.obj-code
        .
      end.
      output close.
    end.
    when "excel":U then do:
        do on stop  undo, return no-apply
           on error undo, return no-apply
           on quit  undo, return no-apply
        :
        run str/docl-prn.p (input parparentproc,
                      input p-curr-host-code,
                      input p-curr-obj-type,
                      input p-curr-obj-code,
                      input "excel":U,
                      output v-Frame-Width) no-error.
          run waitfram-hide in this-procedure .
       end.
    end.
end case.
END PROCEDURE.
PROCEDURE proc-doc-print :
do
on error undo, return error return-value
:
define buffer buf_trn-doc for  ub.trn-doc .
define buffer buf_pr-doc  for  ub.price-doc .
define buffer buf_inkas   for  ub.inkas.
define buffer buf_fbr-doc for  ub.fbr-doc.
define variable v-doc-rec as   recid no-undo .
DEFINE VARIABLE v-frame-width as integer no-undo .
define variable glog as logical no-undo .
if doc-list.doc-type = 'производство':U
or lookup(doc-list.doc-type, 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0
then do:
  message
  "Нет печати для документов производства и заказок/заявок!"
  view-as alert-box .
  return.
end.
if doc-list.doc-type = 'переоценка':U then do:
   find first buf_pr-doc no-lock  where buf_pr-doc.doc-num = doc-list.doc-code no-error .
    v-doc-rec = recid (buf_pr-doc).
    run rep/pr-dprn.w ( input parparentproc
                       ,input v-doc-rec).
end.
else do:
  if doc-list.doc-type = 'касс':U then do:
          find first buf_inkas no-lock where
                     buf_inkas.inkas-code = doc-list.doc-code No-error.
    run rep/sale-prn.p (
            input parparentproc
          , input recid(buf_inkas)
          , input yes
          ).
  end.
  else do:
    find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = doc-list.doc-code no-error .
    v-doc-rec = recid (buf_trn-doc).
    case buf_trn-doc.doc-type
    :
      when 'при':U
      then do:
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_print':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      when 'рас':U
      then do:
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_print':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      when 'спи':U
      then do:
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_print':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      when 'инв':U
      then do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_print':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      when 'возврат':U
      then do:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_print':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" buf_trn-doc.doc-type skip
          "Код документа" buf_trn-doc.doc-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if not glog then return error.
    define buffer buf1_trn-doc for ub.trn-doc  .
    define variable v-spis-recid as character no-undo .
    v-spis-recid = "".
    for each doc-list :
        find first buf1_trn-doc no-lock  where buf1_trn-doc.doc-code = doc-list.doc-code no-error .
        v-spis-recid = v-spis-recid + string(recid (buf1_trn-doc)) + "," .
    end.
    run rep/doc-prn.p (
          input parparentproc
        , input ?
        , input v-spis-recid
    ).
  end.
end.
choice = ?.
end.
END PROCEDURE.
PROCEDURE proc-ex-print :
  do
  on error undo, return error return-value
  :
    run str/doc-xls.p ( input parparentproc, input p-curr-obj-type, input p-curr-obj-code) .
  end.
END PROCEDURE.
procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .
define variable b-c as integer no-undo.
define variable imp-art like ub.goods.artic no-undo .
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define buffer buf_doc-list-hist for doc-list-hist.
do
on error undo, return error
:
  find first buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        AND buf_doc-list-hist.item_ <> '':U .
  run gbl/filename.p
    (input  buf_doc-list-hist.item_
    ,output v-full-path
    ,output v-path
    ,output v-file-name
    ,output v-file-name-no-ext
    ,output v-file-name-ext
    ) no-error .
  if error-status:error then do: end. else do:
    input stream sout from value (v-full-path).
    CASE rs-list-method:
      when "cli-list-trn-doc" then do:
        repeat:
          import stream sout imp-type imp-code no-error.
          for each ub.trn-doc where ub.trn-doc.cli-type = imp-type
                            and ub.trn-doc.cli-code = imp-code no-lock:
              run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode)  .
          end.
        end.
      end.
      when "trn-gds-list" or
      when "price-gds-list" then do:
        define variable v-doc-code as character no-undo .
      repeat:
        import stream sout  imp-type imp-code imp-art no-error.
        if rs-list-method = "price-gds-list" then do:
          for each ub.price-list No-LOCK WHERE
                    ub.price-list.artic = imp-art
                AND ub.price-list.prod-type = imp-type
                AND ub.price-list.prod-code = imp-code
                and ub.price-list.main-price = yes:
            if ub.price-list.doc-num <> v-doc-code then do:
              find first ub.price-doc no-lock where
                          ub.price-doc.doc-num = ub.price-list.doc-num no-error.
              if avail ub.price-doc then do:
                run ex-doc in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode) .
              end.
              v-doc-code = ub.price-list.doc-num.
            end.
          end.
        end.
        else do:
          for each ub.db no-lock,
              each ub.clients no-lock where
                  ub.clients.db-num = ub.db.db-num,
             each ub.doc-line No-LOCK WHERE
                    ub.doc-line.artic = imp-art
                AND ub.doc-line.prod-type = imp-type
                AND ub.doc-line.prod-code = imp-code
                and ub.doc-line.obj-type = ub.clients.obj-type
                and ub.doc-line.obj-code = ub.clients.obj-code:
             if ub.doc-line.doc-code <> v-doc-code then do:
              find first ub.trn-doc no-lock where
                        ub.trn-doc.doc-code = ub.doc-line.doc-code no-error.
              if avail ub.trn-doc then do:
                run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
              end.
              v-doc-code = ub.doc-line.doc-code.
            end.
          end.
        end.
      end.
      end.
      when "file" then do:
        repeat:
          import stream sout imp-doc-code imp-doc-type no-error.
          CASE imp-doc-type:
            when 'переоценка':U then do:
              find first ub.price-doc no-lock where
                        ub.price-doc.doc-num = imp-doc-code No-error.
              if available ub.price-doc then run ex-doc in this-procedure (input 0, input rs-list-method, input rs-status, input line-mode).
            end.
            when 'касс':U then do:
              find first ub.inkas no-lock where
                        ub.inkas.inkas-code = imp-doc-code No-error.
              if available ub.inkas then run ex-doc in this-procedure (input 2, input rs-list-method, input rs-status, input line-mode).
            end.
            when "-" + 'касс':U then do:
              find first ub.c-inkas no-lock where
                        ub.c-inkas.inkas-code = imp-doc-code No-error.
              if available ub.c-inkas then run ex-doc in this-procedure (input 102, input rs-list-method, input rs-status, input line-mode).
            end.
            when 'производство':U then do:
              find first ub.fbr-doc no-lock where
                        ub.fbr-doc.doc-code = imp-doc-code No-error.
              if available ub.fbr-doc then run ex-doc in this-procedure (input 3, input rs-list-method, input rs-status, input line-mode).
            end.
            otherwise do:
              if lookup(imp-doc-type, 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0 then do:
                find first ub.ord-doc no-lock where
                          ub.ord-doc.doc-code = imp-doc-code No-error.
                if available ub.ord-doc then run ex-doc in this-procedure (input 4, input rs-list-method, input rs-status, input line-mode).
              end.
              else do:
                if imp-doc-type begins "-" then do:
                  find first ub.c-trn-doc no-lock where
                            ub.c-trn-doc.doc-code = imp-doc-code No-error.
                  if available ub.trn-doc then run ex-doc in this-procedure (input 101, input rs-list-method, input rs-status, input line-mode).
                end.
                else do:
              find first ub.trn-doc no-lock where
                        ub.trn-doc.doc-code = imp-doc-code No-error.
              if available ub.trn-doc then run ex-doc in this-procedure (input 1, input rs-list-method, input rs-status, input line-mode).
            end.
              end.
            end.
          END CASE.
        end.
      end.
    END CASE.
    input stream sout close.
    assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
end.
end procedure.
PROCEDURE proc-find :
define input parameter loc-find as character no-undo.
case loc-find:
  when "doc-code":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-doc-list no-lock where
                   l-doc-list.doc-code begins sch-code no-error.
    else
        find first l-doc-list no-lock where
                   l-doc-list.doc-code begins sch-code no-error.
  end.
  when "fact-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-doc-list no-lock where
                   l-doc-list.fact-date = sch-date no-error.
    else
        find first l-doc-list no-lock where
                   l-doc-list.fact-date = sch-date no-error.
  end.
end case.
if available l-doc-list then do:
  line-rec = recid (l-doc-list).
  reposition br-list to recid line-rec no-error.
  apply "value-changed" to br-list in frame Dialog-Frame.
end.
else do:
  message
  "Строка не найдена."
  view-as alert-box error.
end.
END PROCEDURE.
procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_doc-list-hist for doc-list-hist.
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
  f-name = "default.trm"
  glog = yes
  .
  system-dialog get-file f-name
  filters "Макрос создания списка документов *.trm" "*.trm"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "trm".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка документов.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_doc-list-hist:
      export stream PrnLibStream
      buf_doc-list-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
end.
end procedure.
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable f-name as char init "default.trn" no-undo.
define variable v-date1 as date no-undo .
define variable v-date2 as date no-undo .
define buffer buf_doc-list-hist for doc-list-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
v-no-hist = - 1.
if  temp-list.fvalue = "single" then
run Myenable in this-procedure .
else do:
  v-no-hist = 0.
  case  rs-list-method:
    when "attr" or when "attr-val" then do:
      run trig-attr in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "trn-doc" then do:
      glog = yes.
      message "Одна или несколько Накладных."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
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
        run Myenable in this-procedure .
        return error.
      end.
      run str/sortdctp.p (input-output ref-list, input no).
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_trn-doc where recid (buf_trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Документ : &1 &2 &3 &4 № &5 от &6"
                              , buf_trn-doc.doc-type
                              , buf_trn-doc.status_
                              , buf_trn-doc.obj-type
                              , buf_trn-doc.obj-code
                              , buf_trn-doc.doc-code
                              , string (buf_trn-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = 'trn-doc':U
          v-bh       = buffer buf_trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Документы :")
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
                                , buf_trn-doc.doc-type
                                , buf_trn-doc.status_
                                , buf_trn-doc.obj-type
                                , buf_trn-doc.obj-code
                                , buf_trn-doc.doc-code
                                , string (buf_trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'trn-doc':U
            v-bh       = buffer buf_trn-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'trn-doc':U
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
    when "trn-doc-fact-date" then do:
      glog = yes.
      message "Все накладные с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'trn-doc':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'trn-doc':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "c-trn-doc" then do:
      glog = yes.
      message "Одна или несколько УДАЛЕННЫХ Накладных."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run str/calldocs.w
                    (input parparentproc
                    ,input 'уд_работа':U
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input 'b-sel,b-mark':U
                    ,input '':U
                    ,input ?
                    ,input ?
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return error.
      end.
      run str/sortdctp.p (input-output ref-list, input yes).
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_c-trn-doc where recid (buf_c-trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("УДАЛЕННЫЙ Документ : &1 &2 &3 &4 № &5 от &6"
                              , buf_c-trn-doc.doc-type
                              , buf_c-trn-doc.status_
                              , buf_c-trn-doc.obj-type
                              , buf_c-trn-doc.obj-code
                              , buf_c-trn-doc.doc-code
                              , string (buf_c-trn-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = 'c-trn-doc':U
          v-bh       = buffer buf_c-trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("УДАЛЕННЫЕ Документы :")
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
                                , buf_c-trn-doc.doc-type
                                , buf_c-trn-doc.status_
                                , buf_c-trn-doc.obj-type
                                , buf_c-trn-doc.obj-code
                                , buf_c-trn-doc.doc-code
                                , string (buf_c-trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'c-trn-doc':U
            v-bh       = buffer buf_c-trn-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'c-trn-doc':U
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
    when "c-trn-doc-fact-date" then do:
      glog = yes.
      message "Все УДАЛЕННЫЕ накладные с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("УДАЛЕННЫЕ Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'c-trn-doc':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("УДАЛЕННЫЕ Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'c-trn-doc':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "price-doc" then do:
      glog = yes.
      message "Одна или несколько Переоценок."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return no-apply.
      end.
      run str/pr-docs.w (
        input parparentproc
        ,input "b-sel,b-mark":U
        ,input (if v-docs-all
              then 'работа':U
              else (if v-docs-cmp
                    then 'фирма':U
                    else 'объект':U
                    )
              )
        ,input ""
        ,input p-curr-obj-type
        ,input p-curr-obj-code
        ,input ""
        ,output ref-list
        ).
      if ref-list = "" then do:
        run MyEnable.
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_price-doc where recid (buf_price-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Переоценка : &1 &2 &3 № &4 от &5"
                              , buf_price-doc.status_
                              , buf_price-doc.obj-type
                              , buf_price-doc.obj-code
                              , buf_price-doc.doc-num
                              , string(buf_price-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = 'price-doc':U
          v-bh       = buffer buf_price-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Переоценки :")
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
            dsp-rs = substitute("&1 &2 &3 № &4 от &5"
                                , buf_price-doc.status_
                                , buf_price-doc.obj-type
                                , buf_price-doc.obj-code
                                , buf_price-doc.doc-num
                                , string(buf_price-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'price-doc':U
            v-bh       = buffer buf_price-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'price-doc':U
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
    when "price-doc-fact-date" then do:
      glog = yes.
      message "Все переоценки с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'price-doc':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'price-doc':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "inkas" then do:
      glog = yes.
      message
      "Одна или несколько отчетов о Продаже."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      ref-list = "" .
      run str/salelist.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input 'фирма':U
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output ref-list) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_inkas where recid (buf_inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
            dsp-rs = substitute("Продажа: &1 &2&3 &4"
                           , buf_inkas.inkas-code
                           , buf_inkas.obj-type
                           , buf_inkas.obj-code
                           , string (buf_inkas.doc-date)
                           )
          v-item     = '':U
          v-tbl-name = 'inkas':U
          v-bh       = buffer buf_inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Продажа: ")
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
            dsp-rs = substitute("&1", buf_inkas.inkas-code)
            v-item     = '':U
            v-tbl-name = 'inkas':U
            v-bh       = buffer buf_inkas:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'inkas':U
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
    when "inkas-fact-date" then do:
      glog = yes.
      message "Все  док-ты продажи с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'inkas':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'inkas':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "c-inkas" then do:
      glog = yes.
      message
      "Один или несколько УДАЛЕННЫХ отчетов о Продаже."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      ref-list = "" .
      run str/salclist.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input ('удаленные':U + chr(44) + 'фирма':U)
                    ,input ''
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output ref-list) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_c-inkas where recid (buf_c-inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
            dsp-rs = substitute("УДАЛЕННАЯ Продажа: &1 &2&3 &4"
                           , buf_c-inkas.inkas-code
                           , buf_c-inkas.obj-type
                           , buf_c-inkas.obj-code
                           , string (buf_c-inkas.doc-date)
                           )
          v-item     = '':U
          v-tbl-name = 'c-inkas':U
          v-bh       = buffer buf_c-inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("УДАЛЕННАЯ Продажа: ")
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
            dsp-rs = substitute("&1", buf_c-inkas.inkas-code)
            v-item     = '':U
            v-tbl-name = 'c-inkas':U
            v-bh       = buffer buf_c-inkas:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'c-inkas':U
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
    when "c-inkas-fact-date" then do:
      glog = yes.
      message "Все УДАЛЕННЫЕ док-ты продажи с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("УДАЛЕННЫЕ продажи с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'c-inkas':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("УДАЛЕННЫЕ продажи с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'c-inkas':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "fbr-doc" then do:
      glog = yes.
      message "Один или несколько документов Производства."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return no-apply.
      end.
      run str/fbr-docs.w ( input parparentproc
                          ,input  ?
                          ,input (if v-docs-all
                                  then 'работа':U
                                  else 'объект':U
                                  )
                          ,input-output ref-list).
      if ref-list = "" then do:
        run MyEnable.
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_fbr-doc where recid (buf_fbr-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Производство : &1 &2 &3 № &4 от &5"
                              , buf_fbr-doc.status_
                              , buf_fbr-doc.obj-type
                              , buf_fbr-doc.obj-code
                              , buf_fbr-doc.doc-code
                              , string(buf_fbr-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = 'fbr-doc':U
          v-bh       = buffer buf_fbr-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Производства :")
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
            dsp-rs = substitute("&1 &2 &3 № &4 от &5"
                                , buf_fbr-doc.status_
                                , buf_fbr-doc.obj-type
                                , buf_fbr-doc.obj-code
                                , buf_fbr-doc.doc-code
                                , string(buf_fbr-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'fbr-doc':U
            v-bh       = buffer buf_fbr-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'fbr-doc':U
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
    when "ord-doc" then do:
      glog = yes.
      message "Один или несколько Заказов/заявок."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run ref/all-zakz.w (
        input   parParentProc
        ,input   "all":U
        ,input   "all":U
        ,input   "firm"
        ,input   ?
        ,input   "b-sel,b-mark"
        ,input   ""
        ,output  ref-list ) .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_ord-doc where recid (buf_ord-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Заказ : &1 &2 &3 &4 № &5 от &6"
                              , buf_ord-doc.doc-type
                              , buf_ord-doc.status_
                              , buf_ord-doc.obj-type
                              , buf_ord-doc.obj-code
                              , buf_ord-doc.doc-code
                              , string (buf_ord-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = 'ord-doc':U
          v-bh       = buffer buf_ord-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Заказы/заявки :")
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
                                , buf_ord-doc.doc-type
                                , buf_ord-doc.status_
                                , buf_ord-doc.obj-type
                                , buf_ord-doc.obj-code
                                , buf_ord-doc.doc-code
                                , string (buf_ord-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = 'ord-doc':U
            v-bh       = buffer buf_ord-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'ord-doc':U
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
    when "ord-doc-fact-date" then do:
      glog = yes.
      message "Все заказы/заявки с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       ref-list = "":U.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                         if not v-user-select then do:     run MyEnable in this-procedure .     return no-apply.   end.
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Заказы/заявки с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input 'ord-doc':U
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Заказы/заявки с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code) + chr(3) +
                      string(v-date1, "99/99/9999") + chr(3) +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input 'ord-doc':U
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end.
    end.
    when "cli-trn-doc" or when "cli-grp-trn-doc" then do:
      glog = yes.
      if rs-list-method = "cli-grp-trn-doc" then do:
        glog = yes.
        message "Накладные контрагентов из 1 или нескольких групп."
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable.
          return error.
        end.
        grp-list = "".
        ref-list = "".
        run ref/cli-grps.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input-output grp-list).
      end.
      else do:
        glog = yes.
        message "Накладные 1 или нескольких контрагентов."
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable in this-procedure .
          return error.
        end.
        grp-list = "".
        run ref/cli-all.w ( input parparentproc
                      ,input "b-sel,b-mark"
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,output ref-list) .
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
            dsp-rs = substitute("Группа контрагентов: &1", grp-path)
            v-item     = '':U
            v-tbl-name = 'cli-grp':U
            v-bh       = buffer ub.cli-grp:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группы контрагентов: ")
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
          run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input 'trn-doc':U
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
            find ub.clients where recid ( ub.clients) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Контрагент :&1", ub.clients.obj-name)
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
              dsp-rs = substitute("Контрагент : ")
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
              dsp-rs = substitute("&1", ub.clients.obj-name)
              v-item     = '':U
              v-tbl-name = 'clients':U
              v-bh       = buffer ub.clients:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input 'trn-doc':U
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
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "cli-list-trn-doc"  then do:
      glog = yes.
      message
      "Все документы по контрагентам " skip
      "из ранее сохраненного в файле списка клиентов" skip
      "(по всем объектам фирмы за все время работы программы)" skip
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      system-dialog get-file f-cli-name
      filters "Списки контрагентов *.cli" "*.cli"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "cli".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input substitute("Файл списка контрагентов: &1", f-cli-name)
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-cli-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "trn-gds-list"
    or
    when "price-gds-list" then do:
      glog = yes.
      if rs-list-method = "trn-gds-list" then
      message
      "Все накладные с товарами из сохраненного в файле списка товаров."
      view-as alert-box question buttons OK-Cancel update glog.
      else
      message
      "Все переоценки с товарами из сохраненного в файле списка товаров."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      system-dialog get-file f-gds-name
      filters "Списки товаров *.gds" "*.gds"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "gds".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      if rs-list-method = "trn-gds-list" then
      dsp-rs = substitute("Накладные на товары списка : &1", f-gds-name).
      else
      dsp-rs = substitute("Переоценки на товары списка : &1", f-gds-name).
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input dsp-rs
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-gds-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "file" then do:
      glog = yes.
      message
      "Все документы из ранее сохраненного в файле списка."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      system-dialog get-file f-doc-name
      filters "Списки документов *.trn" "*.trn"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "trn".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input substitute("Файл списка : &1", f-doc-name)
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-doc-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    WHEN "FILTER-trn"
    or
    when "FILTER-price"
    or
    when "filter-inkas"
    or
    when "filter-fbr"
    THEN DO:
      CASE rs-list-method:
        when "filter-trn" then run trig-filter-trn in this-procedure no-error.
        when "filter-price" then run trig-filter-price in this-procedure no-error.
        when "filter-inkas" then run trig-filter-inkas in this-procedure no-error.
        when "filter-fbr" then run trig-filter-fbr in this-procedure no-error.
      END CASE.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    END.
  end case.
  if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when 1 then do:
        run proc-b-add in this-procedure(input no
                                        ,input ?
                                        ,input rs-list-method
                                        ,input v-table-name
                                        ,input rs-status) no-error  .
      end.
      when 2 then do:
        run proc-b-del in this-procedure(input no
                                        ,input ?
                                        ,input rs-list-method
                                        ,input v-table-name
                                        ,input rs-status ) no-error  .
      end.
      when 3 then do:
        run proc-b-rest in this-procedure(input no
                                         ,input ?
                                         ,input rs-list-method
                                         ,input v-table-name
                                         ,input rs-status) no-error  .
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
  rs-list-method =  temp-list.fvalue
  .
  find last buf_doc-list-hist no-lock where
            buf_doc-list-hist.id = (v-seq - 1)
      and  buf_doc-list-hist.line = 0 no-error .
  DISPLAY
  (if available buf_doc-list-hist
  then buf_doc-list-hist.des
  else '') @ dsp-rs
  with frame Dialog-Frame.
  if tot-lns = 0
  then do:
    run proc-b-add in this-procedure(input no
                                    ,input ?
                                    ,input rs-list-method
                                    ,input v-table-name
                                    ,input rs-status)  .
  end.
end.
END PROCEDURE.
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable imp-ART like ub.goods.ARTIC no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable grp-path like ub.goods.grp-name no-undo.
define variable v-report-num as integer no-undo .
define variable glog as logical no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-date-from  as date no-undo .
define variable v-date-to  as date no-undo .
define buffer buf_doc-list-hist for doc-list-hist.
define buffer buf_user-obj for ub.user-obj.
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
run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input RS-STATUS, input line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame Dialog-Frame = 12.
case rs-list-method:
  when "attr"
  or
  when "attr-val" then do:
    find first buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
         AND buf_doc-list-hist.item_ <> '':U no-error .
    assign
    v-attr-code = entry(1, buf_doc-list-hist.item_, chr(3))
    vvalue = (if rs-list-method = "attr" then '':U else entry(2, buf_doc-list-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
        for each ub.doc-attr No-LOCK WHERE
              ub.doc-attr.attr-code = v-attr-code,
            first ub.trn-doc no-lock where
                 ub.trn-doc.doc-code = ub.doc-attr.doc-code
        :
         if rs-list-method = "attr-val" then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input v-attr-code ,
                       output vvalue1 ,
                       output vtype1 )  .
           if vvalue1 <> vvalue then NEXT.
         end.
       run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  WHEN "PRICE-DOC" THEN DO:
    glog = no.
    _jj:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _jj.
      find first ub.price-doc no-lock where
                rowid(ub.price-doc) = v-rowid no-error.
      if not avail ub.price-doc then next _jj.
      run ex-DOC in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode).
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "price-doc-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.price-doc no-lock where
                 ub.price-doc.obj-type = buf_user-obj.obj-type
             and ub.price-doc.obj-code = buf_user-obj.obj-code
             and ub.price-doc.fact-date >= v-date-from
             and ub.price-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  WHEN "fbr-DOC" THEN DO:
    glog = no.
    _jj:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _jj.
      find first ub.fbr-doc no-lock where
                rowid(ub.fbr-doc) = v-rowid no-error.
      if not avail ub.fbr-doc then next _jj.
      run ex-DOC in this-procedure(input 3, input rs-list-method, input rs-status, input line-mode).
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  WHEN "TRN-DOC" THEN DO:
    glog = no.
    _ii:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _ii.
      find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
      if not avail ub.trn-doc then next _ii.
      run ex-DOC in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "trn-doc-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.trn-doc no-lock where
                 ub.trn-doc.obj-type = buf_user-obj.obj-type
             and ub.trn-doc.obj-code = buf_user-obj.obj-code
             and ub.trn-doc.fact-date >= v-date-from
             and ub.trn-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  WHEN "c-trn-doc" THEN DO:
    glog = no.
    _ii:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _ii.
      find first ub.c-trn-doc no-lock where
              rowid(ub.c-trn-doc) = v-rowid no-error.
      if not avail ub.c-trn-doc then next _ii.
      run ex-DOC in this-procedure(input 101, input rs-list-method, input rs-status, input line-mode) .
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "c-trn-doc-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.c-trn-doc no-lock where
                 ub.c-trn-doc.obj-type = buf_user-obj.obj-type
             and ub.c-trn-doc.obj-code = buf_user-obj.obj-code
             and ub.c-trn-doc.fact-date >= v-date-from
             and ub.c-trn-doc.fact-date <= v-date-to
             and ub.c-trn-doc.is-del = yes:
            run ex-DOC in this-procedure(input 101, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  WHEN "inkas" THEN DO:
   for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
      and  buf_doc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first ub.inkas no-lock where
                rowid( ub.inkas) = v-rowid no-error.
      if available ub.inkas then do:
         run ex-DOC in this-procedure(input 2, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "inkas-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.inkas no-lock where
                 ub.inkas.obj-type = buf_user-obj.obj-type
             and ub.inkas.obj-code = buf_user-obj.obj-code
             and ub.inkas.fact-date >= v-date-from
             and ub.inkas.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 2, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  WHEN "c-inkas" THEN DO:
   for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
      and  buf_doc-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first ub.c-inkas no-lock where
                rowid(ub.c-inkas) = v-rowid no-error.
      if available ub.c-inkas then do:
         run ex-DOC in this-procedure(input 102, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "c-inkas-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.c-inkas no-lock where
                 ub.c-inkas.obj-type = buf_user-obj.obj-type
             and ub.c-inkas.obj-code = buf_user-obj.obj-code
             and ub.c-inkas.fact-date >= v-date-from
             and ub.c-inkas.fact-date <= v-date-to
             and ub.c-inkas.is-del = yes :
            run ex-DOC in this-procedure(input 102, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  WHEN "ord-doc" THEN DO:
    glog = no.
    _ii:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _ii.
      find first ub.ord-doc no-lock where
              rowid(ub.ord-doc) = v-rowid no-error.
      if not avail ub.ord-doc then next _ii.
      run ex-DOC in this-procedure(input 4, input rs-list-method, input rs-status, input line-mode) .
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "ord-doc-fact-date" then do:
     for each buf_doc-list-hist where
            buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_doc-list-hist.item_, chr(3))
      v-obj-code = integer(entry(2, buf_doc-list-hist.item_, chr(3)))
      v-date-from =     date(entry(3, buf_doc-list-hist.item_, chr(3)))
      v-date-to = date(entry(4, buf_doc-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.ord-doc no-lock where
                 ub.ord-doc.obj-type = buf_user-obj.obj-type
             and ub.ord-doc.obj-code = buf_user-obj.obj-code
             and ub.ord-doc.fact-date >= v-date-from
             and ub.ord-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 4, input rs-list-method, input rs-status, input line-mode) .
            assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  when "cli-trn-doc" then do:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find ub.clients where rowid ( ub.clients) = v-rowid no-lock.
      for each ub.trn-doc no-lock where
                ub.trn-doc.cli-type = ub.clients.obj-type AND
                ub.trn-doc.cli-code = ub.clients.obj-code:
        run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
      end.
      assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "cli-grp-trn-doc" then do:
    for each buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
        and  buf_doc-list-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_doc-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find ub.cli-grp where rowid (ub.cli-grp) = v-rowid no-lock.
      grp-path = "".
      run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
      for each ub.clients where
                ub.clients.grp-name begins grp-path no-lock,
          each ub.trn-doc no-lock where
                ub.trn-doc.cli-type = ub.clients.obj-type AND
                ub.trn-doc.cli-code = ub.clients.obj-code:
        run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode).
      end.
     assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
     end.
   end.
   when "cli-list-trn-doc"
   or
   when "trn-gds-list"
   or
   when "price-gds-list"
   or
   when "file"
   then do:
     run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
   end.
  when "filter-trn"
  or
  when "filter-price"
  or
  when "filter-inkas"
  then do:
    define variable v-filter-var as character no-undo .
    find first buf_doc-list-hist where
             buf_doc-list-hist.id = p-id
         AND buf_doc-list-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_doc-list-hist.item_ , output v-filter-var).
    CASE rs-list-method:
      when "filter-trn" then
      run gbl/doc-fill.p (input 1
                   ,input "Формирование списка по фильтру накладных (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input 'trn-doc':U
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   )
                  .
      when "filter-price" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру переоценок (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input 'price-doc':U
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
      when "filter-fbr" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру производств (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input 'fbr-doc':U
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
      when "filter-inkas" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру продаж (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input 'inkas':U
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
    END CASE.
    assign                                                           buf_doc-list-hist.num-add  = lns-cnt - v-num-add                       buf_doc-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_doc-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_doc-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
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
end CASE.
if line-mode <> 'ОСТАВИТЬ':U then
  run Myenable in this-procedure.
end.
END PROCEDURE.
PROCEDURE trig-attr :
define input parameter rs-list-method as character no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable v-item               as character           no-undo .
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable vproc-attr       as character no-undo .
define variable vfull-screen-val as character no-undo .
assign
ref-list = ""
vattr-codes = ""
vattr-labels = ""
vvalue = ""
.
define variable v-ii as integer   no-undo .
v-ii = num-entries('hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U) .
DO ii = 1 to v-ii :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input entry( ii, 'hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U ) ,
                       output vtype ,
                       output vformat ,
                       output vfillin_width ,
                       output vfillin_height ,
                       output vlabel ,
                       output vuser-can-edit ,
                       output voutput-display ,
                       output vother  ,
                       output vproc-attr ,
                       output vfull-screen-val ,
                       output vsort
                       ) no-error .
    if not error-status :error and voutput-display = yes then do:
        assign
        vattr-codes = vattr-codes + chr(126) + entry(ii, 'hold-part-code,dov,dids,dateinv,nids,ddog,ndog,dsf,nsf,addsum,clcasol,clcaswt,scanfile,indoclnsum,purchlimit,purchcodelist,expense_own,envd,fbroperator,fbrauto,0rsrv-date,1ord_time,21ord_phone,22ord_contact,2befpay,3ord_Nchek,4dchek,first-price,4ord_dl,5deliv,6sumwrk,7sumsrk,8ord_adr,9ord_hwo,1postpay,2postNchek,3postdchek,QntyPlace,discnt-stop,discnt-other,m_inc,DFinDoc,NFinDoc,PlaceStorage,Packer,Dispath,price-target,edi,negais,egais,ddov,ndov,Recipient,Shipper,Auto,Driver,print-num,idCountryContr,olsuppcntr,t_pass-fname,t_pass-position,t_accept-fname,t_accept-position,ndovwho,car-time,nosn,relprpdf,ora-exp-seq-num,need-saledc,ser_on_pack,cargo-desc,carry-type,cargo-mass,exp-trans,zakaz-number,zakaz-date,delivery-date,delivery-time,,autoent,car-num,fio-driver,date-income,,inspection-cert,condition,seals-condition,doc-not,spisok-not-doc,is-fuel,is-lgas,is-lgas-corr,othermoves,is-return,clear-ac,edo-return,trdcattr-is-not-close-fact-news,trdcattr-prikaz-number,trdcattr-prikaz-date,trdcattr-inv-date,trdcattr-fio-agent,trdcattr-pos-agent,trdcattr-fio-player1,trdcattr-pos-player1,trdcattr-fio-player2,trdcattr-pos-player2,trdcattr-fio-player3,trdcattr-pos-player3':U)
        vattr-labels = vattr-labels + chr(126) + vlabel
        .
    end.
end.
run gbl/d-list.w ("b-sel":U,
            "Выберите атрибут документа",
             vattr-codes,
             vattr-labels,
             chr(126),
             "":U,
             output v-attr-code).
if v-attr-code = "" then do:
  return error.
end.
glog = yes.
if rs-list-method = "attr" then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input v-attr-code ,
                       output vtype ,
                       output vformat ,
                       output vfillin_width ,
                       output vfillin_height ,
                       output vlabel ,
                       output vuser-can-edit ,
                       output voutput-display ,
                       output vother  ,
                       output vproc-attr ,
                       output vfull-screen-val ,
                       output v-sort
                       ) no-error .
    message
    "Все документы с установленным атрибутом " + vlabel
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ документы с установленным атрибутом &1", vlabel)
    v-item = v-attr-code
    .
end.
else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input v-attr-code ,
                       output vtype ,
                       output vformat ,
                       output vfillin_width ,
                       output vfillin_height ,
                       output vlabel ,
                       output vuser-can-edit ,
                       output voutput-display ,
                       output vother  ,
                       output vproc-attr ,
                       output vfull-screen-val ,
                       output v-sort
                       )  .
    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута документа" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = 'L':U then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=':u  + string(vfillin_width) + '\':u
    + 'fillin_height=':u + string(vfillin_height) + '\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message
    substitute("Все документы с атрибутом &1 = &2" , vlabel, vvalue)
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ документы с атрибутом &1 = &2", vlabel, vvalue)
    v-item = v-attr-code + chr(3) + vvalue
    .
end.
v-no-hist = 0.
run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input 'trn-doc':U
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
PROCEDURE trig-filter-inkas :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.
glog = yes.
message
"Все продажи, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_salelist" + chr(4) + "Список продаж" + chr(4) + "no"
.
assign
tbl = 'inkas':U
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('inkas-code', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bge-date', 'Вн.проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Сумма нетто', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', 'Скидка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', 'Сумма брутто', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk', 'Кол-во чеков', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty', 'Кол-во товара', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                      , input-output v-seq
                                      , input 0
                                      , input 'inkas':U
                                      , input '':U
                                      , input substitute("Фильтр продаж: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.
END PROCEDURE.
PROCEDURE trig-filter-fbr :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.
glog = yes.
message
"Все производства, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_prdoclist" + chr(4) + "Список производств" + chr(4) + "no"
.
assign
tbl = 'fbr-doc':U
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                      , input-output v-seq
                                      , input 0
                                      , input 'fbr-doc':U
                                      , input '':U
                                      , input substitute("Фильтр документов производства: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.
END PROCEDURE.
PROCEDURE trig-filter-price :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.
glog = yes.
message
"Все переоценки, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_prdoclist" + chr(4) + "Список переоценок" + chr(4) + "no"
.
assign
tbl = 'price-doc':U
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-num', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rest-qnty', 'Кол-во', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rest-sale', 'Сумма До пер-ки (баз. вал.)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sale-base', 'Сумма по док. (баз. вал.)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                      , input-output v-seq
                                      , input 0
                                      , input 'price-doc':U
                                      , input '':U
                                      , input substitute("Фильтр переоценок: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.
END PROCEDURE.
PROCEDURE trig-filter-trn :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.
glog = yes.
message "Все накладные, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_trndoclist" + chr(4) + "Список накладных" + chr(4) + "no"
.
assign
tbl = 'trn-doc':U
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ext-doc-type', 'Расш.тип', 'ext-doc-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('flag_', 'OK', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type*cli-code', 'Контрагент', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss', 'Менеджер', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-rubl', 'Сумма (руб)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-rubl', 'Скидка (руб)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-type', 'Тип скидки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('internal', 'Внутренняя', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-name', 'Название контр-а', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Создал', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt', 'Исполнитель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'На док-т', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('base-rate', 'Курс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inv-num', 'Инвойс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ord-num', 'Заказ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('print-rubl', 'Рублевый', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-num', 'Отгрузка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date', 'Дата отгрузки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ov', 'Акт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-ov', 'Сумма акта', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code', 'Валюта', 'cur',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                      , input-output v-seq
                                      , input 0
                                      , input 'trn-doc':U
                                      , input '':U
                                      , input substitute("Фильтр накладных: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
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
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-doc-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input p-table-name
                                        , input get-hist-mode(line-mode)
                                        , input substitute("Документ &1 от &2 &3&4 (факт.дата &5)"
                                                          , doc-list.doc-code
                                                          , string(doc-list.doc-date, "99/99/9999")
                                                          , doc-list.obj-type
                                                          , doc-list.obj-code
                                                          , string(doc-list.fact-date, "99/99/9999")
                                                          )
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input (p-table-name + chr(3) + doc-list.doc-code)
                                        , input ''
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-doc-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input p-table-name
                                          , input get-hist-mode(line-mode)
                                          , input substitute("Документ &1 от &2 &3&4 (факт.дата &5)"
                                                            , doc-list.doc-code
                                                            , string(doc-list.doc-date, "99/99/9999")
                                                            , doc-list.obj-type
                                                            , doc-list.obj-code
                                                            , string(doc-list.fact-date, "99/99/9999")
                                                            )
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input (p-table-name + chr(3) + doc-list.doc-code)
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-doc-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                        , input-output  v-temp-seq
                                        , input v-ii
                                        , input p-table-name
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
FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character) :
  case loc-doc-type:
    when 'переоценка':U then do:
    assign
    dcli-type = ""
    dcli-code = ?
    dcli-name = "Переоценка"
    .
    find first ub.price-doc no-lock where
               ub.price-doc.doc-num = doc-list.doc-code No-ERROR.
    if avail ub.price-doc then
    ddoc-ps = ub.price-doc.PS.
    else ddoc-ps = "".
    return dcli-type.
  end.
    when 'производство':U  then do:
      assign
      dcli-type = ""
      dcli-code = ?
      dcli-name = "Производство"
      .
      find first ub.fbr-doc no-lock where
                ub.fbr-doc.doc-code = doc-list.doc-code No-ERROR.
      if avail ub.fbr-doc then
      ddoc-ps = ub.fbr-doc.PS.
      else ddoc-ps = "".
      return dcli-type.
    end.
    otherwise do:
      if lookup(loc-doc-type, 'ОФ,ФП,ОП,ОО,ОР,ПО') > 0 then do:
        FIND FIRST ub.ord-doc No-LOCK WHERE
                  ub.ord-doc.doc-code = loc-doc-code No-ERROR.
        if not avail ub.ord-doc then do:
          assign
          dcli-type = "?"
          dcli-code = ?
          dcli-name = "Заказ/заявка не найдены"
          ddoc-ps = ""
          .
          return dcli-type.
        end.
        assign
        dcli-type = ub.ord-doc.cli-type
        dcli-code = ub.ord-doc.cli-code
        ddoc-ps = ub.ord-doc.PS
        .
        find first ub.clients no-lock where
                  ub.clients.obj-type = ub.ord-doc.cli-type AND
                  ub.clients.obj-code = ub.ord-doc.cli-code No-ERROR.
        if not avail ub.clients then do:
            assign
            dcli-name = "Контрагент по заказу/заявке не найден"
            .
            return dcli-type.
        end.
        assign
        dcli-name = ub.clients.obj-name
        .
        return dcli-type.
      end.
      else do:
        if loc-doc-type begins "-" then do:
          FIND FIRST ub.c-trn-doc No-LOCK WHERE
                    ub.c-trn-doc.doc-code = loc-doc-code No-ERROR.
          if not avail ub.c-trn-doc then do:
            assign
            dcli-type = "?"
            dcli-code = ?
            dcli-name = "Документ не найден"
            ddoc-ps = ""
            .
            return dcli-type.
          end.
          assign
          dcli-type = ub.c-trn-doc.cli-type
          dcli-code = ub.c-trn-doc.cli-code
          ddoc-ps = ub.c-trn-doc.PS
          .
          find first ub.clients no-lock where
                    ub.clients.obj-type = ub.c-trn-doc.cli-type AND
                    ub.clients.obj-code = ub.c-trn-doc.cli-code No-ERROR.
          if not avail ub.clients then do:
            assign
            dcli-name = "Контрагент по документу не найден"
            .
            return dcli-type.
          end.
          assign
          dcli-name = ub.clients.obj-name
          .
          return dcli-type.
        end.
        else do:
      FIND FIRST ub.trn-doc No-LOCK WHERE
                ub.trn-doc.doc-code = loc-doc-code No-ERROR.
          if not avail ub.trn-doc then do:
        assign
        dcli-type = "?"
        dcli-code = ?
        dcli-name = "Документ не найден"
        ddoc-ps = ""
        .
        return dcli-type.
    end.
    assign
    dcli-type = ub.trn-doc.cli-type
    dcli-code = ub.trn-doc.cli-code
    ddoc-ps = ub.trn-doc.PS
    .
    find first ub.clients no-lock where
               ub.clients.obj-type = ub.trn-doc.cli-type AND
               ub.clients.obj-code = ub.trn-doc.cli-code No-ERROR.
    if not avail ub.clients then do:
        assign
        dcli-name = "Контрагент по документу не найден"
        .
        return dcli-type.
    end.
    assign
    dcli-name = ub.clients.obj-name
    .
    return dcli-type.
  end.
    end.
  end.
end case.
  RETURN "".
END FUNCTION.
