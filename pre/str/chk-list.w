define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирования списка чеков и чеков МЦ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define  SHARED  temp-table chk-list no-undo
field doc-code   like ub.chk-doc.doc-code
field obj-type   like ub.chk-doc.obj-type
field obj-code   like ub.chk-doc.obj-code
field out-code   like ub.chk-doc.out-code
field chk-date   like ub.chk-doc.chk-date
field chk-time   like ub.chk-doc.chk-time
field shift-date like ub.chk-doc.shift-date
field shift-num  like ub.chk-doc.shift-num
field shift-name  like ub.chk-doc.shift-name
field src-shift-date like ub.chk-doc.src-shift-date
field chk-num    like ub.chk-doc.chk-num
field pay-desk   like ub.chk-doc.pay-desk
field cashier    like ub.chk-doc.cashier
field cashier-psn-code    like ub.chk-doc.cashier-psn-code
field chk-type   like ub.chk-doc.chk-type
field d-card     like ub.chk-doc.d-card
field netto      like ub.chk-doc.netto
field discnt     like ub.chk-doc.discnt
field tot-doc    like ub.chk-doc.tot-doc
field is-wth     as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
field doc-num    as character label "№ док-та" format "X(22)"
field doc-num2   as character label "№ заказа" format "X(22)"
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   SHARED   temp-table chk-list-hist no-undo
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
procedure create-chk-list-hist :
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
define buffer buf_chk-list-hist for chk-list-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_chk-list-hist where
                   buf_chk-list-hist.id = 0   no-error.
        if not available buf_chk-list-hist then do:
          create buf_chk-list-hist.
          assign
          buf_chk-list-hist.id = 0
          buf_chk-list-hist.line = 0
          buf_chk-list-hist.list-table = '':U
          .
        end.
        assign
        buf_chk-list-hist.des =  p-des
        buf_chk-list-hist.num-recs = p-num-recs
        buf_chk-list-hist.option_  = p-option
        buf_chk-list-hist.item_ = p-item
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
        create buf_chk-list-hist.
        assign
        buf_chk-list-hist.id = p-seq
        buf_chk-list-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_chk-list-hist.des =  p-des
        buf_chk-list-hist.line = p-line
        buf_chk-list-hist.num-recs = p-num-recs
        buf_chk-list-hist.option_  = p-option
        buf_chk-list-hist.item_ = p-item
        buf_chk-list-hist.hist-mode =  p-hist-mode
        buf_chk-list-hist.status_ =  p-status_
        buf_chk-list-hist.num-add = v-num-add
        buf_chk-list-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_chk-list-hist where
                  buf_chk-list-hist.id = p-seq
              and buf_chk-list-hist.line = p-line no-error .
        if  available buf_chk-list-hist then do:
          assign
          buf_chk-list-hist.des =  p-des
          buf_chk-list-hist.num-recs = p-num-recs
          buf_chk-list-hist.option_  = p-option
          buf_chk-list-hist.item_ = p-item
          buf_chk-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_chk-list-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_chk-list-hist where
                  buf_chk-list-hist.id = p-seq
              and buf_chk-list-hist.line = p-line  no-error .
        if available buf_chk-list-hist then do:
          assign
          buf_chk-list-hist.hist-mode =  p-hist-mode
          buf_chk-list-hist.num-recs  = (if buf_chk-list-hist.line = 0 then p-num-recs else buf_chk-list-hist.num-recs)
          buf_chk-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_chk-list-hist.list-table)
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
        buf_chk-list-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_chk-list-hist.item_ = "!ERROR"
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-chk-list for chk-list
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-chk-list.shift-name.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-chk-list.obj-type,
                       input  loc-chk-list.obj-code,
                       input  loc-chk-list.shift-date,
                       input  loc-chk-list.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer l-chk-list for chk-list.
define variable f-chk-name as char init "default.chk" no-undo.
define variable f-doc-name as char init "default.trn" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-card-name as char init "default.dc" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable grp-list as char no-undo.
define variable is-grp as logical no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable num-rec2 as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable kk as integer no-undo .
define variable v-doc-code like ub.chk-doc.doc-code no-undo .
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine VARiable RS-list-method AS CHARACTER.
define variable save-option as character no-undo.
define variable print-option as character no-undo.
define variable ddoc-PS like ub.clients.obj-name no-undo.
define variable glog as logical no-undo .
define variable v-ref-list as character no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable rs-status as character no-undo .
define variable lns-ignore as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-tab-order as character no-undo .
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable v-object-available as logical   no-undo .
define variable v-cpdoc-attr-val as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define temp-table temp-list no-undo
field fname as character format "X(30)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.
define variable f-name as char init "default.chk" no-undo.
FUNCTION get-table-name returns character(input p-is-wth as logical):
CASE p-is-wth:
  when yes then return 'chk-doc':U.
  otherwise return 'chk-doc':U.
END CASE.
END FUNCTION.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION get-chk-type RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-chk-type as integer,
    input loc-is-wth as logical)  FORWARD.
FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.
DEFINE MENU MENU-B-save
       MENU-ITEM m_chk-save     LABEL "Файл списка чеков"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m_xls-save2     LABEL "Таблица EXCEL (с выбором полей)"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка".
DEFINE MENU MENU-B-print
       MENU-ITEM m_short   LABEL "Список чеков"
       MENU-ITEM m_gds     LABEL "Список строк чеков(товарных)"
       MENU-ITEM m_gds-excel LABEL "Список строк чеков(товарных) в EXCEL"
       MENU-ITEM m_gds-pay LABEL "Содержимое товар.чеков"
       MENU-ITEM m_one     LABEL "Один чек"
       .
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 20 BY 1 TOOLTIP "Добавление в список чеков 1 строки".
DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".
DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все чеки (строки)".
DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 20 BY 1 TOOLTIP "Удаление из списка чеков 1 строки".
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
     SIZE 3 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего чека".
DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1 TOOLTIP "Печать текущего чека".
DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".
DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 20 BY 1 TOOLTIP "Оставить в списке чеков только текущую строку".
DEFINE BUTTON B-save
     LABEL "Со&хранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить список чеков в текстовом файле, EXCEL".
DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 71 BY 1.54 NO-UNDO.
DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE CHK-STATUS AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 34.75 BY 1 NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Нач. №"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE sch-chk-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата чека"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE sch-shift-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата см.(учета)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE v-end-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE v-start-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE QUERY BR-list FOR
      chk-list SCROLLING.
DEFINE QUERY br-option FOR
      temp-list SCROLLING.
DEFINE BROWSE BR-list
  QUERY BR-list DISPLAY
      chk-list.doc-code format "X(22)"
      chk-list.obj-type
      chk-list.obj-code
      chk-list.chk-date
      string(chk-list.chk-time, "hh:mm:ss":U)
      chk-list.chk-num COLUMN-LABEL "№ чека!на кассе" format "->>>>99999"
      chk-list.pay-desk
      chk-list.cashier
      chk-list.cashier-psn-code
      chk-list.out-code
      chk-list.shift-date COLUMN-LABEL "Дата смены!учета"
      shift-name-no-err(buffer chk-list) COLUMN-LABEL "№ смены" FORMAT "X(6)"
      get-chk-type(chk-list.doc-code, chk-list.chk-type, chk-list.is-wth) COLUMN-LABEL "Тип чека" FORMAT "X(10)"
      chk-list.d-card
      chk-list.netto
      chk-list.discnt
      chk-list.tot-doc
      chk-list.doc-num
      chk-list.doc-num2
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70 BY 15.13.
DEFINE BROWSE BR-option
  QUERY br-option
  DISPLAY
    temp-list.fname format "X(40)"
    WITH NO-LABELS SEPARATORS SIZE 26 BY 21 TOOLTIP "Условие для выбора чеков, которые будут добавлены/удалены/оставлены".
DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-option AT ROW 2 COL 72
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-lkp AT ROW 2 COL 21
     B-clr AT ROW 2 COL 31
     B-macro AT ROW 2 COL 51
     B-stop AT ROW 2 COL 55
     B-clear-macro AT ROW 2 COL 55
     B-record AT ROW 2 COL 55
     f-tot-lns AT ROW 2 COL 60 COLON-ALIGNED NO-LABEL
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 31
     B-rest AT ROW 3 COL 51
     CHK-STATUS at row 4 col 2 no-label
     v-start-date at row 4 col 38
     v-end-date at row 4 col 53
     BR-list AT ROW 5.21 COL 1.25
     sch-code AT ROW 20.5 COL 1
     sch-chk-date AT ROW 20.5 COL 30 COLON-ALIGNED
     sch-shift-date AT ROW 20.5 COL 58 COLON-ALIGNED
     ED-notes AT ROW 21.54 COL 1 NO-LABEL
     SPACE(21.36) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список чеков"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame      = MENU MENU-B-print:HANDLE
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
define buffer buf-chk-list-hist for chk-list-hist.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  glog = no.
message "Удаление всех строк списка. Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each chk-list:
  delete chk-list.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-chk-list-hist:
  delete buf-chk-list-hist.
end.
run create-chk-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список чеков очищен."
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
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define buffer buf_chk-list-hist for chk-list-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
find first buf_chk-list-hist no-lock where buf_chk-list-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка чеков "
(if available buf_chk-list-hist
then buf_chk-list-hist.des
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
for each buf_chk-list-hist where buf_chk-list-hist.id > 0
by buf_chk-list-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_chk-list-hist.line = 0
   then string(buf_chk-list-hist.id, ">>>>>>>>9")
   else fill(chr(32) , 9)
  )  chr(32)
  (if buf_chk-list-hist.item_ <> '':U
   then string(buf_chk-list-hist.hist-mode, "X(8)")
   else fill( chr(32), 8)) chr(32)
  string(buf_chk-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
  string(buf_chk-list-hist.num-recs, ">>>>>>>>9")  chr(32)
  string(buf_chk-list-hist.des, "X(155)") skip.
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
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
 if not available chk-list then do:
  message "Неправильно выбран чек."
          view-as alert-box error.
  return no-apply.
 end.
 run str/showchk.p (
                 input parparentproc
                ,input chk-list.doc-code
                ,input chk-list.is-wth
                ,input this-procedure:handle
              ) no-error .
 apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable v-frame-width as integer no-undo.
if print-option = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error or print-option = "":U then return no-apply.
end.
CASE print-option:
  when "short":U then do:
    print-option = ''.
    run str/chkl-prn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U
                  ,input '':U
                  ,output v-Frame-Width) no-error.
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
  end.
  when 'chk-gds':U then do:
    print-option = ''.
    run str/chklgprn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U
                  ,output v-Frame-Width) no-error.
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
  end.
  when 'chk-gds':U + chr(44) + 'excel':U then do:
    print-option = ''.
    run str/chklgprx.p (
                   input parparentproc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ) no-error.
  end.
  when ('chk-gds':U + chr(44) + 'chk-pay':U) then do:
    print-option = ''.
    run str/chklsprn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U
                  ,output v-Frame-Width) no-error.
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
  end.
  when "one":U then do:
    print-option = "":U.
    if not available chk-list then do:
      message
      "Нет чека для печати"
      view-as alert-box .
      apply "entry" to br-list in frame Dialog-Frame.
    end.
    if chk-list.is-wth then do:
      run str/checkwp.p (input parparentproc, chk-list.doc-code) no-error.
    end.
    else do:
      run str/checkp.p (input parparentproc, chk-list.doc-code) no-error.
    end.
  end.
END CASE.
assign
print-option = "":U.
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if save-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   run proc-b-save in this-procedure(save-option) no-error.
   if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF BR-list IN FRAME Dialog-Frame
DO:
  if avail chk-list then do:     assign ed-notes = ddoc-ps.     display ed-notes     tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   else do:     assign ed-notes = ''.     display ed-notes     tot-lns @ f-tot-lns with frame Dialog-Frame.   end.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  apply "VALUE-changed" to CHK-STATUS in frame Dialog-Frame .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_chk-save
DO:
    assign
  save-option = "chk-list":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gds
DO:
    assign
  print-option =  'chk-gds':U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gds-excel
DO:
  assign
  print-option =  'chk-gds':U + chr(44) + 'excel':U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gds-pay
DO:
  assign
  print-option = 'chk-gds':U + chr(44) + 'chk-pay':U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
    assign
  print-option = "one":U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-macros-save  DO:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF MENU-ITEM m_short
DO:
    assign
  print-option = "short":U.
  apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-title-save
DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ЧЕКОВ" + '\':u
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
run create-chk-list-hist in this-procedure (input 'title'
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
frame Dialog-Frame:title = substitute("СПИСОК ЧЕКОВ &1", v-value).
END.
ON CHOOSE OF MENU-ITEM m_xls-save
DO:
    assign
  save-option = "excel":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_xls-save2
DO:
    assign
  save-option = "excel2":U.
  apply "choose" to b-save in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF CHK-STATUS IN FRAME Dialog-Frame DO:
define variable v-today as date no-undo .
define variable v-time as integer no-undo .
define variable v-old-status as character no-undo .
  run cur-time in this-procedure (
                                  output v-today
                                 ,output v-time).
  assign
  v-old-status = CHK-STATUS
  CHK-STATUS
  .
    if CHK-STATUS = "chk-date":U
    then do:
      if v-start-date = ? or v-end-date = ? then
      assign
      v-start-date = date(month(v-today - 1), 1, year(v-today))
      v-end-date = v-today - 1.
      RS-STATUS = CHK-STATUS + chr(4) + string(v-start-date, "99/99/9999") + chr(4) + string(v-end-date, "99/99/9999")
      .
      display
      v-start-date
      v-end-date
      with frame Dialog-Frame .
    end.
    else do:
      assign
      v-start-date = ?
      v-end-date = ?
      RS-STATUS = CHK-STATUS
      .
      hide
      v-start-date
      v-end-date
      in frame Dialog-Frame .
    end.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  assign
  sch-code.
  run proc-find in this-procedure("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
    assign
  sch-code.
  run proc-find in this-procedure("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CTRL-J OF sch-chk-date IN FRAME Dialog-Frame
DO:
   assign
  sch-chk-date.
  run proc-find in this-procedure("chk-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF sch-chk-date IN FRAME Dialog-Frame
DO:
   assign
  sch-chk-date.
  run proc-find in this-procedure("chk-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CTRL-J OF sch-shift-date IN FRAME Dialog-Frame
DO:
   assign
  sch-shift-date.
  run proc-find in this-procedure("shift-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF sch-shift-date IN FRAME Dialog-Frame
DO:
   assign
  sch-shift-date.
  run proc-find in this-procedure("shift-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON LEAVE OF v-end-date IN FRAME Dialog-Frame
DO:
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
 assign
 v-end-date.
 RS-STATUS = CHK-STATUS + chr(4) + string(v-start-date, "99/99/9999") + chr(4) + string(v-end-date, "99/99/9999").
END.
ON LEAVE OF v-start-date IN FRAME Dialog-Frame
DO:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  assign
  v-start-date.
  RS-STATUS = CHK-STATUS + chr(4) + string(v-start-date, "99/99/9999") + chr(4) + string(v-end-date, "99/99/9999").
END.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
on any-printable of br-list in frame Dialog-Frame do:
  apply "entry" to sch-code in frame Dialog-Frame.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dialog-Frame DO:
    apply "choose" to b-lkp in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-chk :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-process as logical no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
  CASE entry(1, rs-status, chr(4)):
    when "chk-date":U then do:
      ASSIGN
      V-START-DATE = DATE(ENTRY(2, rs-status, chr(4)))
      V-END-DATE = DATE(ENTRY(3, rs-status, chr(4)))
      rs-status = entry(1, rs-status, chr(4))
      .
    end.
  END CASE.
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    find first chk-list where
              chk-list.doc-code = ub.chk-doc.doc-code
              no-error.
    if available chk-list then do:
      if rs-list-method = "single":U or           (rs-status = 'все':U            or            (chk-doc.out-code = ? and rs-status = "free":U)            or            (chk-doc.chk-date >= v-start-date and chk-doc.chk-date <= v-end-date and rs-status = "chk-date":U)           )
      then do:
        assign
        v-process = yes
        .
      end.
      if line-mode = 'удаление':U and v-process then do:
        if chk-list.doc-code <> v-doc-code then
        lns-cnt = lns-cnt + 1.
        delete chk-list.
      end.
      if line-mode = 'ОСТАВИТЬ':U and  v-process then do:
        if chk-list.to-del = ? then .
        else do:
          if chk-list.doc-code <> v-doc-code then
          lns-cnt = lns-cnt + 1.
          assign chk-list.to-del = ?.
        end.
      end.
      if not v-process
      and chk-list.doc-code <> v-doc-code
      then
      assign
      lns-ignore = lns-ignore + 1
      .
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U then do:
      if rs-list-method = "single":U or           (rs-status = 'все':U            or            (chk-doc.out-code = ? and rs-status = "free":U)            or            (chk-doc.chk-date >= v-start-date and chk-doc.chk-date <= v-end-date and rs-status = "chk-date":U)           ) then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find chk-list
  where chk-list.doc-code = chk-doc.doc-code
  no-error .
if available chk-list then do:
  assign
    chk-list.to-del = no
  .
end.
else do:
  create chk-list .
  assign
  chk-list.doc-code   = chk-doc.doc-code
  chk-list.obj-type   = chk-doc.obj-type
  chk-list.obj-code   = chk-doc.obj-code
  chk-list.out-code   = chk-doc.out-code
  chk-list.chk-date  = chk-doc.chk-date
  chk-list.chk-time  = chk-doc.chk-time
  chk-list.shift-date = chk-doc.shift-date
  chk-list.shift-num  = chk-doc.shift-num
  chk-list.src-shift-date = chk-doc.src-shift-date
  chk-list.chk-num    = chk-doc.chk-num
  chk-list.pay-desk   = chk-doc.pay-desk
  chk-list.cashier    = chk-doc.cashier
  chk-list.cashier-psn-code   = chk-doc.cashier-psn-code
  chk-list.chk-type   = chk-doc.chk-type
  chk-list.d-card     = chk-doc.d-card
  chk-list.is-wth     = LOOKUP(string(chk-doc.chk-type), '2,3,4,5,7':U) > 0
  chk-list.doc-num    = chk-doc.doc-num
  chk-list.doc-num2   = chk-doc.doc-num2
  chk-list.to-del = no
  .
  if chk-list.is-wth = no then do:
    assign
    chk-list.netto      = buffer chk-doc:handle:buffer-field("netto"):buffer-value
    chk-list.tot-doc    = buffer chk-doc:handle:buffer-field("tot-doc"):buffer-value
    chk-list.discnt     = buffer chk-doc:handle:buffer-field("discnt"):buffer-value
    no-error
    .
  end.
  else do:
    assign
    chk-list.netto      = 0
    chk-list.tot-doc    = 0
    chk-list.discnt     = 0
    no-error
    .
  end.
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (chk-list)
  .
end.
      end.
      else assign
      lns-ignore = lns-ignore + 1
      .
    end.
  if lns-cnt modulo 25 = 0 then
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame Dialog-Frame.
end PROCEDURE.
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf-chk-list-hist for chk-list-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each chk-list:
      delete chk-list.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-chk-list-hist:
      delete buf-chk-list-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-chk-list-hist in this-procedure (
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
  if not available chk-list then return no-apply.
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
if not available chk-list then return no-apply.
  assign rs-list-method = "single".
 run proc-b-rest in this-procedure(
                                                input no
                                               ,input ?
                                               ,input rs-list-method
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
run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
define buffer buf_chk-list-hist for chk-list-hist.
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
run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
for each buf_chk-list-hist where
        buf_chk-list-hist.id >=  an-listp-start-macro-id
  and  buf_chk-list-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_chk-list-hist
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
      v-num-entries-options = num-entries("Текущая строка,single,                       Чек (товарный),chk-doc,                       Чек продажи,inkas,                            Чек документа МЦ,wth-doc,                     Чеки. с товаром,goods,                        Чеки с типом касс. платежа,cash-pay,          Чеки с ОСС,chk-oss,                           Чеки по дисконтной карте,d-card,              Чеки. с тов. из списка,gds-list,              Чеки МЦ с определенной МЦ,wealth,             Чеки с определенным кол-вом тов.строк,gds-line-num,             Чеки (товарный) определенного типа,chk-type,  Файл,file,                                    Фильтр товарных строк чеков,filter-chk-gds,   Фильтр строк оплат чеков,filter-chk-pay,      Фильтр чеков,filter-chk-doc,                  Фильтр чеков с разн.по запр.за нал,filter-chk-doc-autotank, С атрибутом оплаты,cpdoc-attr,               Атрибут оплаты =,cpdoc-attr-val")
    .
    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,"Текущая строка,single,                       Чек (товарный),chk-doc,                       Чек продажи,inkas,                            Чек документа МЦ,wth-doc,                     Чеки. с товаром,goods,                        Чеки с типом касс. платежа,cash-pay,          Чеки с ОСС,chk-oss,                           Чеки по дисконтной карте,d-card,              Чеки. с тов. из списка,gds-list,              Чеки МЦ с определенной МЦ,wealth,             Чеки с определенным кол-вом тов.строк,gds-line-num,             Чеки (товарный) определенного типа,chk-type,  Файл,file,                                    Фильтр товарных строк чеков,filter-chk-gds,   Фильтр строк оплат чеков,filter-chk-pay,      Фильтр чеков,filter-chk-doc,                  Фильтр чеков с разн.по запр.за нал,filter-chk-doc-autotank, С атрибутом оплаты,cpdoc-attr,               Атрибут оплаты =,cpdoc-attr-val"
                                     )
                               ,chr(32)
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,"Текущая строка,single,                       Чек (товарный),chk-doc,                       Чек продажи,inkas,                            Чек документа МЦ,wth-doc,                     Чеки. с товаром,goods,                        Чеки с типом касс. платежа,cash-pay,          Чеки с ОСС,chk-oss,                           Чеки по дисконтной карте,d-card,              Чеки. с тов. из списка,gds-list,              Чеки МЦ с определенной МЦ,wealth,             Чеки с определенным кол-вом тов.строк,gds-line-num,             Чеки (товарный) определенного типа,chk-type,  Файл,file,                                    Фильтр товарных строк чеков,filter-chk-gds,   Фильтр строк оплат чеков,filter-chk-pay,      Фильтр чеков,filter-chk-doc,                  Фильтр чеков с разн.по запр.за нал,filter-chk-doc-autotank, С атрибутом оплаты,cpdoc-attr,               Атрибут оплаты =,cpdoc-attr-val"
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
define buffer buf_chk-list-hist for chk-list-hist.
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
        for each buf_chk-list-hist where
                buf_chk-list-hist.id >=  an-listp-start-macro-id
          and  buf_chk-list-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_chk-list-hist
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
        filters "Макрос формирования списка *.chm" "*.chm"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "chm".
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
                              ,input 'chk-list'
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
    run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
               ,input "Макрос формирования списка чеков" + chr(4) + "chm"
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
    run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
define  buffer buf_chk-list-hist for chk-list-hist.
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
        for each chk-list:
          delete chk-list.
        end.
        for each chk-list-hist where chk-list-hist.id > an-listp-macros-label-id:
          delete chk-list-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_chk-list-hist.
        buffer-copy macro-list-hist
        to buf_chk-list-hist
        assign buf_chk-list-hist.id = v-seq
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
          find first  buf_chk-list-hist where
                  buf_chk-list-hist.id = v-seq - 1 no-error .
          if available buf_chk-list-hist then
          assign
          macro-list-hist.num-recs = buf_chk-list-hist.num-recs
          macro-list-hist.num-add = buf_chk-list-hist.num-add
          macro-list-hist.num-ignored = buf_chk-list-hist.num-ignored
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
              create buf_chk-list-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_chk-list-hist
              assign
              buf_chk-list-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
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
            for each buf_chk-list-hist where
                    buf_chk-list-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_chk-list-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_chk-list-hist.num-recs
               buf_macro-list-hist.num-add = buf_chk-list-hist.num-add
               buf_macro-list-hist.num-ignored = buf_chk-list-hist.num-ignored
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
    for each chk-list:
      if chk-list.to-del = ? then do:
        assign
        chk-list.to-del = no
        .
      end.
      else do:
        delete chk-list.
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-list :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-chk-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-chk-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-chk-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-chk-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-chk-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-chk-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date39
    MENU-ITEM m-ed-date39-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date39-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date39-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date39-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-chk-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-chk-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date39 :HANDLE
      sch-chk-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle39 as handle no-undo .
  assign
    v-label-handle39 = sch-chk-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle39)
  then do:
    if v-label-handle39 :tooltip = ""
    or v-label-handle39 :tooltip = ?
    then do:
      assign
        v-label-handle39 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date39-1 in menu m-ed-date39 DO:
    apply "ctrl-b":U to sch-chk-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-2 in menu m-ed-date39 DO:
    apply "ctrl-d":U to sch-chk-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-3 in menu m-ed-date39 DO:
    apply "ctrl-e":U to sch-chk-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-4 in menu m-ed-date39 DO:
    apply "ctrl-f":U to sch-chk-date in frame Dialog-Frame .
  END.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-shift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date41
    MENU-ITEM m-ed-date41-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date41-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date41-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date41-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-shift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-shift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date41 :HANDLE
      sch-shift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle41 as handle no-undo .
  assign
    v-label-handle41 = sch-shift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle41)
  then do:
    if v-label-handle41 :tooltip = ""
    or v-label-handle41 :tooltip = ?
    then do:
      assign
        v-label-handle41 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date41-1 in menu m-ed-date41 DO:
    apply "ctrl-b":U to sch-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date41-2 in menu m-ed-date41 DO:
    apply "ctrl-d":U to sch-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date41-3 in menu m-ed-date41 DO:
    apply "ctrl-e":U to sch-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date41-4 in menu m-ed-date41 DO:
    apply "ctrl-f":U to sch-shift-date in frame Dialog-Frame .
  END.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of v-start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of v-start-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of v-start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of v-start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of v-start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date43
    MENU-ITEM m-ed-date43-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date43-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date43-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date43-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-start-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-start-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date43 :HANDLE
      v-start-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle43 as handle no-undo .
  assign
    v-label-handle43 = v-start-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle43)
  then do:
    if v-label-handle43 :tooltip = ""
    or v-label-handle43 :tooltip = ?
    then do:
      assign
        v-label-handle43 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date43-1 in menu m-ed-date43 DO:
    apply "ctrl-b":U to v-start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date43-2 in menu m-ed-date43 DO:
    apply "ctrl-d":U to v-start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date43-3 in menu m-ed-date43 DO:
    apply "ctrl-e":U to v-start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date43-4 in menu m-ed-date43 DO:
    apply "ctrl-f":U to v-start-date in frame Dialog-Frame .
  END.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of v-end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of v-end-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of v-end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of v-end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of v-end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date45
    MENU-ITEM m-ed-date45-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date45-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date45-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date45-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-end-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-end-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date45 :HANDLE
      v-end-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle45 as handle no-undo .
  assign
    v-label-handle45 = v-end-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle45)
  then do:
    if v-label-handle45 :tooltip = ""
    or v-label-handle45 :tooltip = ?
    then do:
      assign
        v-label-handle45 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date45-1 in menu m-ed-date45 DO:
    apply "ctrl-b":U to v-end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-2 in menu m-ed-date45 DO:
    apply "ctrl-d":U to v-end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-3 in menu m-ed-date45 DO:
    apply "ctrl-e":U to v-end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-4 in menu m-ed-date45 DO:
    apply "ctrl-f":U to v-end-date in frame Dialog-Frame .
  END.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 run get-report-num in parparentproc ( output g#report-num ).
  assign
  line-rec = ?
  .
  run proc-fill-temp-list in this-procedure .
  ASSIGN
  b-print:MENU-MOUSE = 1
  b-save:MENU-MOUSE = 1
  .
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY dsp-rs sch-code sch-chk-date sch-shift-date ED-notes f-tot-lns CHK-STATUS
          v-end-date v-start-date
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs B-exit B-save B-print B-hist B-lkp B-clr B-Help
         B-add B-del B-rest B-macro B-stop B-clear-macro B-record BR-list sch-code
         sch-chk-date sch-shift-date ED-notes f-tot-lns CHK-STATUS v-end-date
         v-start-date
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-list FOR EACH chk-list NO-LOCK.     open query br-option for each temp-list no-lock .
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-start as logical no-undo .
define variable v-recid0 as recid no-undo.
define buffer buf_temp-list for temp-list.
define buffer buf_chk-list-hist for chk-list-hist.
assign
CHK-STATUS:radio-buttons in frame Dialog-Frame
= "Неучтенные&+" + chr(44) + "free":U + chr(44) +
                          "Все!" + chr(44) + 'все':U + chr(44) +
                          "В диапазоне дат-" + chr(44) + "chk-date":U
CHK-STATUS = (if CHK-STATUS = "":U then 'все':U else CHK-STATUS)
.
find first buf_chk-list-hist where buf_chk-list-hist.id = 0 no-error.
if available buf_chk-list-hist then
assign
frame Dialog-Frame:title = substitute("СПИСОК  ЧЕКОВ &1",  string(buf_chk-list-hist.des, "X(60)"))
.
br-option:column-scrolling in frame Dialog-Frame  = no.
  if tot-lns = ? then do:
  v-start = yes.
  for each l-chk-list :
    accumulate l-chk-list.obj-code (count).
  end.
  tot-lns = (accum count l-chk-list.obj-code).
  if tot-lns > 0 then do:
    find last  buf_chk-list-hist no-error .
    v-seq = (if available buf_chk-list-hist then buf_chk-list-hist.id else 0)  + 1.
    run create-chk-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
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
    for each buf_chk-list-hist:
      delete buf_chk-list-hist.
    end.
    v-seq = 1.
    run create-chk-list-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input "# Исходный список чеков пуст."
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
find last buf_chk-list-hist no-lock where
          buf_chk-list-hist.id = (v-seq - 1)
      and  buf_chk-list-hist.line = 0 no-error .
DISPLAY br-option
(if available buf_chk-list-hist
then buf_chk-list-hist.des
else '') @ dsp-rs
CHK-STATUS WITH FRAME Dialog-Frame.
ENABLE
b-macro  when v-start
b-record when v-start
b-exit b-add b-hist b-help br-option br-list CHK-STATUS WITH FRAME Dialog-Frame.
if v-start then do:
  hide
  b-stop
  b-clear-macro
  in frame Dialog-Frame.
end.
v-start = no.
hide sch-code in frame Dialog-Frame
sch-chk-date in frame Dialog-Frame
sch-shift-date in frame Dialog-Frame
.
ENABLE
b-exit
b-add
b-hist
b-help
br-list
br-option
CHK-STATUS
v-start-date
v-end-date
WITH FRAME Dialog-Frame.
apply "VALUE-changed" to CHK-STATUS.
reposition br-option to recid v-recid0.
if tot-lns > 0 then
  ENABLE
  b-print
  b-rest
  b-save
  b-del
  b-lkp
  b-clr
  sch-code
  sch-chk-date
  sch-shift-date
  WITH FRAME Dialog-Frame.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr sch-code sch-chk-date sch-shift-date WITH FRAME Dialog-Frame.
end.
if tot-lns = ? or tot-lns = 0 then do:
  hide sch-code sch-chk-date sch-shift-date in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame.
apply "VALUE-changed" to CHK-STATUS.
run openbr in this-procedure.
if line-rec <> ? then
  reposition br-list to recid line-rec no-error.
if avail chk-list then do:     assign ed-notes = ddoc-ps.     display ed-notes     tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   else do:     assign ed-notes = ''.     display ed-notes     tot-lns @ f-tot-lns with frame Dialog-Frame.   end.
END PROCEDURE.
PROCEDURE OpenBr :
        Open query br-list
        for each chk-list No-LOCK indexed-reposition.
APPLY "ENTRY" to br-list in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
line-mode = 'ДОБАВЛЕНИЕ':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
  end.
  else do:
    v-rid-list = ''.
    run str/chk-docs.w (
                 input parparentproc
                ,input "b-sel":U
                ,input 'объект':U
                ,input ?
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input ?
                ,input "":U
                ,input 0
                ,input ?
                ,input ?
                ,input 0
                ,output v-rid-list
                ).
    apply "entry" to br-list in frame Dialog-Frame.
    if v-rid-list = "" then return error.
    find first chk-doc where recid (chk-doc) = integer (v-rid-list) no-lock no-error .
  end.
  if (not p-from-macro and available chk-doc)
  or (p-from-macro and  available chk-doc)
  then do:
    run ex-chk in this-procedure (
                                 input rs-list-method
                               , input rs-status
                               , input line-mode).
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).
  end.
  else do:
    return error "Нет в БД такого чека".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define variable v-rep-rec as recid no-undo .
line-mode = 'удаление':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
    find first chk-list where chk-list.doc-code = chk-doc.doc-code no-error.
  end.
  if available chk-list then do:
    line-rec = recid (chk-list).
    get next br-list.
    if available chk-list then v-rep-rec = recid (chk-list).
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available chk-list then v-rep-rec = recid (chk-list).
    end.
    reposition br-list to recid line-rec no-error.
    tot-lns = tot-lns - 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).
    delete chk-list.
    line-rec = v-rep-rec.
    run Myenable in this-procedure.
  end.
  else do:
    return error "Нет в списке чеков такого чека".
  end.
end.
else do:
  glog = no.
  message "Удалить чеки из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
  if not glog then
    return error.
  run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
end.
END PROCEDURE.
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define variable glog as logical no-undo .
define buffer buf_chk-list-hist for chk-list-hist.
line-mode = 'ОСТАВИТЬ':U.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
    find first chk-list where chk-list.doc-code = chk-doc.doc-code no-error.
  end.
  if available chk-list then do:
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return no-apply.
    end.
    line-rec = recid (chk-list).
    v-seq = 1.
    for each buf_chk-list-hist:
      delete buf_chk-list-hist.
    end.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input RS-STATUS, input line-mode).
    for each chk-list:
      if line-rec <> recid (chk-list) then delete chk-list.
    end.
    tot-lns = 1.
    run Myenable in this-procedure .
  end.
  else do:
    return error substitute("Нет в списке такого чека").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message "Оставить чеки в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
  for each chk-list:
    if chk-list.to-del = ? then do:
      assign
      chk-list.to-del = no
      .
    end.
    else do:
      delete chk-list.
    end.
  end.
  tot-lns = lns-cnt.
  run Myenable in this-procedure.
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
case loc-save-option:
  when "chk-list":U then do:
    assign
    f-chk-name = "default.chk"
    glog = yes
    .
    system-dialog get-file f-chk-name
    filters "Списки чеков *.chk" "*.chk"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "chk".
    if not glog then do:
      apply "entry" to br-list in frame Dialog-Frame.
      return no-apply.
    end.
    run waitfram-show in this-procedure ("Ждите" ).
    output to value (f-chk-name).
    for each chk-list:
      export
      chk-list.doc-code
      chk-list.chk-type
      chk-list.obj-type
      chk-list.obj-code
      chk-list.chk-date
      chk-list.chk-time
      chk-list.chk-num
      chk-list.pay-desk
      chk-list.cashier
      chk-list.out-code
      .
    end.
    output close.
    run waitfram-hide in this-procedure .
  end.
  when "excel":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
    :
      run str/chkl-prn.p ( input parparentproc
                      ,input "excel":U
                      ,input "":U
                      ,input '':U
                      ,output v-Frame-Width) no-error.
      run waitfram-hide in this-procedure .
    end.
  end.
  when "excel2":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
    :
      run str/chkl-prx.p (
                   input parparentproc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ) no-error.
      run waitfram-hide in this-procedure .
    end.
  end.
end case.
END PROCEDURE.
PROCEDURE proc-find :
define input parameter loc-find as character no-undo.
case loc-find:
  when "doc-code":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-chk-list no-lock where
                   l-chk-list.doc-code begins sch-code no-error.
    else
        find first l-chk-list no-lock where
                   l-chk-list.doc-code begins sch-code no-error.
  end.
  when "chk-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-chk-list no-lock where
                   l-chk-list.chk-date = sch-chk-date no-error.
    else
        find first l-chk-list no-lock where
                   l-chk-list.chk-date = sch-chk-date no-error.
  end.
  when "shift-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-chk-list no-lock where
                   l-chk-list.shift-date = sch-shift-date no-error.
    else
        find first l-chk-list no-lock where
                   l-chk-list.shift-date = sch-shift-date no-error.
  end.
end case.
if available l-chk-list then do:
  line-rec = recid (l-chk-list).
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
define buffer buf_chk-list-hist for chk-list-hist.
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
    f-name = "default.chm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка чеков *.chm" "*.chm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "chm".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка чеков.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_chk-list-hist:
      export stream PrnLibStream
      buf_chk-list-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure.
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable v-chk-types as character no-undo .
define variable v-chk-names as character no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
define variable v-recs as integer no-undo .
define variable v-recs2 as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-ref-row as character no-undo .
define variable v-ref-rec2 as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable f-name as char init "default.chk" no-undo.
define variable v-prev-type as character no-undo .
define variable v-prev-code as integer no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_chk-list-hist for chk-list-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_wealth for ub.wealth.
define buffer buf_goods for ub.goods.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
define variable v-cpdoc-attr-code as character no-undo.
define variable v-cpdoc-attr-name as character no-undo.
v-no-hist = - 1.
if  temp-list.fvalue = "single" then
run Myenable in this-procedure.
else do:
  v-no-hist = 0.
  case  rs-list-method:
    when "chk-doc" then do:
      glog = yes.
      message
      "Один или несколько Чеков (товарных)"
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      v-ref-list = "":u.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                          if not v-user-select then do:     run Myenable in this-procedure .     return no-apply.   end.
      run str/chk-docs.w (
                     input parparentproc
                    ,input "b-sel,b-mark":U
                    ,INPUT (if CHK-STATUS = 'все':U
                            then 'объект':U
                            else CHK-STATUS)
                    ,input ?
                    ,input v-sel-obj-type
                    ,input v-sel-obj-code
                    ,input ?
                    ,input "":U
                    ,input 0
                    ,input v-start-date
                    ,input v-end-date
                    ,input 0
                    ,output v-rid-list
                    ).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_chk-doc where recid (buf_chk-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чек(товарный) : &1 &2&3 &4 &5"
                           , buf_chk-doc.doc-code
                           , buf_chk-doc.obj-type
                           , buf_chk-doc.obj-code
                           , string (buf_chk-doc.chk-date)
                           , stat-line(CHK-STATUS)
                           )
            v-item     = '':U
            v-tbl-name = 'chk-doc':U
            v-bh       = buffer buf_chk-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Чек : &1", stat-line(CHK-STATUS))
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
              dsp-rs = substitute("&1", buf_chk-doc.doc-code)
              v-item     = buf_chk-doc.doc-code
              v-tbl-name = 'chk-doc':U
              v-bh       = buffer buf_chk-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "inkas" then do:
      glog = yes.
      assign       CHK-STATUS = 'все':U.       display       CHK-STATUS       with frame Dialog-Frame.
      message "Все чеки одной или нескольких продаж."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      v-ref-list = "":u.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                          if not v-user-select then do:     run Myenable in this-procedure .     return no-apply.   end.
      v-rid-list = '':U.
      run str/salelist.w (
                     parparentproc
                   , "b-sel,b-mark"
                   , 'объект':U
                   , 0
                   , v-sel-obj-type
                   , v-sel-obj-code
                   , input-output v-rid-list).
      if v-rid-list = "" then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_inkas where recid (buf_inkas) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Продажа: &1 &2&3 &4 &5"
                           , buf_inkas.inkas-code
                           , buf_inkas.obj-type
                           , buf_inkas.obj-code
                           , string (buf_inkas.doc-date)
                           , stat-line(CHK-STATUS)
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
              dsp-rs = substitute("Продажа: &1", stat-line(CHK-STATUS))
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
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "wth-doc" then do:
      glog = yes.
      assign       CHK-STATUS = 'все':U.       display       CHK-STATUS       with frame Dialog-Frame.
      message
      "Чеки МЦ одного или нескольких Автодокументов МЦ."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      v-ref-list = "":u.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                          if not v-user-select then do:     run Myenable in this-procedure .     return no-apply.   end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-sel-obj-type
  ,input  v-sel-obj-code
  ,output v-host-code
  )  .
       v-rid-list = '':U.
      run str/wth-docs.w (
                     input parparentproc
                   , input "b-sel,b-mark"
                   , input 'объект':U
                   , input v-host-code
                   , input v-sel-obj-type
                   , input v-sel-obj-code
                   , input "":U
                   , input 0
                   , input 'при':U
                   , input '':U
                   , input '':U
                   , input-output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_wth-doc where recid (buf_wth-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Автодокумент МЦ: &1 &2&3 &4 &5"
                           , buf_wth-doc.doc-code
                           , buf_wth-doc.obj-type
                           , buf_wth-doc.obj-code
                           , string (buf_wth-doc.doc-date)
                           , stat-line(CHK-STATUS)
                           )
            v-item     = '':U
            v-tbl-name = 'wth-doc':U
            v-bh       = buffer buf_wth-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Автодокумент МЦ: &1", stat-line(CHK-STATUS))
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
              dsp-rs = substitute("&1", buf_wth-doc.doc-code)
              v-item     = '':U
              v-tbl-name = 'wth-doc':U
              v-bh       = buffer buf_wth-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure (
                                                input 'ДОБАВЛЕНИЕ':U
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
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "d-card" then do:
      glog = yes.
      message "Чеки по одной или нескольким дисконтным картам."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      run ref/discards.w (
                       input parparentproc
                      ,input "b-mark,b-sel":U
                      ,input 'все':U
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input '':U
                      ,input ?
                      ,output v-rid-list
                     ).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
          _carta:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_dis-card where recid (buf_dis-card) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                 and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1
          then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Дисконтная карта: &1 &2&3 &4&5 &6"
                           , buf_dis-card.d-card
                           , buf_dis-card.cli-type
                           , buf_dis-card.cli-code
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = buf_dis-card.d-card + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Дисконтная карта: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _carta.
              if num-rec2 = 0 then NEXT _object .
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_dis-card.d-card, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item    = buf_dis-card.d-card + chr(3) + buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else (num-rec + num-rec2)).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
          .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "goods" then do:
      glog = yes.
      message
      "Чеки с определенными товарами."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
      if v-recs2 = 1 then do:
        find first userobjs_temp-user-obj no-lock.
      end.
      run ref/gds-ref.p (
                       input parparentproc
                     , input 'b-mark,b-sel'
                     , input ?
                     , input ?
                     , input (if v-recs2 = 1 then ? else 'все':U)
                     , input ?
                     , input ?
                     , input ?
                     , input ?
                     , input (if v-recs2 = 1 then userobjs_temp-user-obj.obj-type else p-curr-obj-type)
                     , input (if v-recs2 = 1 then userobjs_temp-user-obj.obj-code else p-curr-obj-code)
                     , input ?
                     , output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _tovar:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_goods where recid (buf_goods) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and  buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Товар: &1 &2 &3&4 &5 &6&7 &8"
                           , buf_goods.gds-code
                           , buf_goods.artic
                           , buf_goods.prod-type
                           , buf_goods.prod-code
                           , buf_goods.gds-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item    = string(buf_goods.gds-code) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Товар: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _tovar.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_goods.gds-code, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item    = string(buf_goods.gds-code) + chr(3) +
                          buf_userobjs_temp-user-obj.obj-type + chr(3) +
                          string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
          .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "gds-list" then do:
      glog = yes.
      message "Чеки с товарами из сохраненного в файле списка товаров."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
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
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      system-dialog get-file f-gds-name
      filters "Списки товаров *.gds" "*.gds"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "gds".
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
      do num-rec = 0 to v-recs2:
        if v-recs2 = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                 and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
        end.
        if v-recs2 = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Чеки &1&2 с товарами из Файла списка товаров: &3 &4"
                                                             , buf_userobjs_temp-user-obj.obj-type
                                                             , buf_userobjs_temp-user-obj.obj-code
                                                             , f-gds-name
                                                             , stat-line(CHK-STATUS))
          v-item    = f-gds-name + chr(3) +
                      buf_userobjs_temp-user-obj.obj-type + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code)
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чеки с товарами из Файла списка товаров: &1 &2"
                                                              , f-gds-name
                                                              , stat-line(CHK-STATUS))
            v-item     = '':U
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
            v-item     = f-gds-name + chr(3) + buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input '':U
                                            , input ?
                                            ).
       if num-rec = 0 or v-recs2 = 1 then v-seq  = v-temp-seq.
       assign
       v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
       v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
      end.
    end.
    when "cash-pay" then do:
      glog = yes.
      message "Чеки с определенными Типами кассового платежа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
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
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
      run ref/cashpays.w ( input parparentproc
                    ,input "b-sel,b-mark":U
                    ,input 'все':U
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _cashpay:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_cash-pay where recid (buf_cash-pay) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип кассового платежа: &1 (код валюты &3) &4&5 &6"
                           , buf_cash-pay.cdpay-code
                           , buf_cash-pay.curr-code
                           , buf_cash-pay.obj-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item = string(buf_cash-pay.cdpay-code) + chr(3) +
                     string(buf_cash-pay.curr-code) + chr(3) +
                    buf_userobjs_temp-user-obj.obj-type + chr(3) +
                    string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип кассового платежа: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _cashpay.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1&2 &3&4"
                                  , buf_cash-pay.cdpay-code
                                  , buf_cash-pay.curr-code
                                  , buf_userobjs_temp-user-obj.obj-type
                                  , buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_cash-pay.cdpay-code) + chr(3) +
                       string(buf_cash-pay.curr-code) + chr(3) +
                       buf_userobjs_temp-user-obj.obj-type + chr(3) +
                       string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "chk-oss" then do:
      glog = yes.
      message "Чеки с ОСС."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      assign v-rid-list = "".
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
       run ref/oss-ref.w ( input parparentproc
                          ,input "v-sel":U
                          ,input 0
                          ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _oss:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-row = entry (num-rec, v-rid-list).
            find first buf_ext-classif where rowid (buf_ext-classif) = to-rowid (v-ref-row) no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("ОСС: &1  &3&4 &5"
                           , buf_ext-classif.CharKey_One
                           , buf_ext-classif.Key#_One
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item = string(buf_ext-classif.CharKey_One) + chr(3) +
                     string(buf_ext-classif.Key#_One) + chr(3) +
                    buf_userobjs_temp-user-obj.obj-type + chr(3) +
                    string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("ОСС: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _oss.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1&2 &3&4"
                                  , buf_ext-classif.CharKey_One
                                  , buf_ext-classif.Key#_One
                                  , buf_userobjs_temp-user-obj.obj-type
                                  , buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_ext-classif.CharKey_One) + chr(3) +
                       string(buf_ext-classif.Key#_One) + chr(3) +
                       buf_userobjs_temp-user-obj.obj-type + chr(3) +
                       string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "wealth" then do:
      glog = yes.
      message "Чеки МЦ с определенными МЦ."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      v-rid-list = '':U.
      run ref/wth-ref.w ( input parparentproc
                         ,input "b-mark,b-sel":U
                         ,input p-curr-host-code
                         ,input p-curr-obj-type
                         ,input p-curr-obj-code
                         ,input 'все':U
                         ,input-output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
        _wth:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_wealth where recid (buf_wealth) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Материальная ценность: &1 &2 &3&4 &5"
                           , buf_wealth.wth-code
                           , buf_wealth.wth-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = string(buf_wealth.wth-code) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Материальные ценности: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _wth.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_wealth.wth-code, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_wealth.wth-code) + chr(3) +
                       buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "gds-line-num" then do:
      glog = yes.
      message "Количество товарных строк."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      assign
      v-rid-list = "0"
      .
      run gbl/d-prompt.w (
        'title=':u + "Количество товарных строк" + '\':u
      + 'format=>9' + '\':u
      + 'type=' + 'I':U + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u
      + 'readonly=no' + '\':u
      , input-output v-rid-list
      ).
      if return-value = 'false':u then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs
  )  .
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, v-ref-list)).
          find first buf_userobjs_temp-user-obj where
                  (buf_userobjs_temp-user-obj.obj-type = v-prev-type
              and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
              or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Чеки &1&2 с количеством товарных строк = &3 &4"
                                                             , buf_userobjs_temp-user-obj.obj-type
                                                             , buf_userobjs_temp-user-obj.obj-code
                                                             , v-rid-list
                                                             , stat-line(CHK-STATUS))
          v-item    = v-rid-list + chr(3) + buf_userobjs_temp-user-obj.obj-type +
                     chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чеки с числом товарных строк = &1 &2"
                                                              , v-rid-list
                                                              , stat-line(CHK-STATUS))
            v-item     = '':U
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
            v-item     = v-rid-list + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input '':U
                                            , input ?
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        assign
        v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
        v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
      end.
    end.
    when "chk-type" then do:
      glog = yes.
      message "Чеки (товарные) определенного типа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      assign
      v-rid-list = ""
      .
      assign
      v-chk-types = '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U
      v-chk-names = 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Приход_Корр,Расход_Корр':U
      .
      run gbl/d-list.w (
              INPUT "b-sel,b-mark":U
              ,INPUT "Выберите типы чеков"
              ,INPUT v-chk-types
              ,INPUT v-chk-names
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
        _receipt:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип чека: &1 &2&3 &4"
                           , entry (lookup (entry(1, v-rid-list), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = entry(num-rec, v-rid-list) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип чека: &1"
                                 , stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _receipt.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", entry (lookup (entry(num-rec, v-rid-list), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U), buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item     = entry(num-rec, v-rid-list) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
      do ii = 1 to num-entries(v-rid-list):
        v-chk-names = v-chk-names + (if v-chk-names = '':U then '':U else (chr(44) + chr(32))) +
                      entry (lookup (entry(ii, v-rid-list), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U).
      end.
      dsp-rs = dsp-rs + chr(32) + substitute("Чеки (товарные) типа: &1", v-chk-names).
    end.
    when "wth-chk-type" then do:
      glog = yes.
      message "Чеки МЦ определенного типа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
      assign
      v-rid-list = ""
      .
      assign
      v-chk-types = '2,3,4,5,7':U
      v-chk-names = 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U
      .
      run gbl/d-list.w (
              INPUT "b-sel,b-mark":U
              ,INPUT "Выберите типы чеков МЦ"
              ,INPUT v-chk-types
              ,INPUT v-chk-names
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-rid-list).
      IF v-rid-list = "":u THEN do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      if v-rid-list <> "" and  v-rid-list <> ? then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
        assign
        v-recs = num-entries (v-rid-list)
        .
        _chk-type:
        do num-rec = 0 to v-recs:
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2:
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип чека: &1 &2&3 &4"
                           , entry (lookup (entry(1, v-rid-list),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U)
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = entry(num-rec, v-rid-list) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип чека: &1"
                                 , stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _chk-type.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", entry (lookup (entry(num-rec, v-rid-list),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U), buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item     = entry(num-rec, v-rid-list) + chr(3) +
                         buf_userobjs_temp-user-obj.obj-type + chr(3) + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
        end.
        end.
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "cpdoc-attr":U then do:
        glog = yes.
        message "Чеки с атрибутом оплаты"
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
            run Myenable in this-procedure.
            return no-apply.
        end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
        assign v-rid-list = "".
        v-cpdoc-attr-code = 'rrn,cpdoc,RTA_RefundExport,CPAgreement,CPWithdrawal,QRPay':U.
        v-cpdoc-attr-name = 'РРН,Остальные,Перевод на моб.счет(ТСО),По аннулированному чеку,Суммы для выдачи наличными,QRPay':U.
        run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input v-cpdoc-attr-code
                    ,input v-cpdoc-attr-name
                    ,input chr(44)
                    ,input "":U
                    ,output v-rid-list).
          dsp-rs = "Чеки с атрибутом оплаты " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + " на объектах ".
          for each buf_userobjs_temp-user-obj no-lock :
              dsp-rs = dsp-rs + buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code) + " ".
          end.
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
    end.
    when "cpdoc-attr-val":U then do:
        glog = yes.
        message "Чеки с атрибутом оплаты ="
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
            run Myenable in this-procedure.
            return no-apply.
        end.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
        assign v-rid-list = "".
        v-cpdoc-attr-code = 'rrn,cpdoc,RTA_RefundExport,CPAgreement,CPWithdrawal,QRPay':U.
        v-cpdoc-attr-name = 'РРН,Остальные,Перевод на моб.счет(ТСО),По аннулированному чеку,Суммы для выдачи наличными,QRPay':U.
        run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input v-cpdoc-attr-code
                    ,input v-cpdoc-attr-name
                    ,input chr(44)
                    ,input "":U
                    ,output v-rid-list).
        run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + "Значение атрибута " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + '\':u
      + 'format=' + "" + '\':u
      + 'type=' + "CHAR" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u
      + 'readonly=no\':u
      , input-output v-cpdoc-attr-val
      ).
          dsp-rs = "Чеки с атрибутом оплаты " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + "=" + v-cpdoc-attr-val + " на объектах ".
          for each buf_userobjs_temp-user-obj no-lock :
              dsp-rs = dsp-rs + buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code) + " ".
          end.
          run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
    end.
    when "file":U then do:
      glog = yes.
      message "Чеки из ранее сохраненного в файле списка."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      system-dialog get-file f-chk-name
      filters "Списки чеков *.chk" "*.chk"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update glog
      default-extension "chk".
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Все чеки из сохраненного в файле списка чеков &1 &2", f-chk-name, stat-line(CHK-STATUS))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-chk-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    WHEN "FILTER-chk-doc" or
    when "filter-chk-gds" or
    when "filter-chk-pay" or
    when "FILTER-chk-doc-autotank"
    THEN DO:
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
                            if not v-user-select then do:     run Myenable in this-procedure.     return no-apply.   end.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs2
  )  .
      CASE rs-list-method:
        when "filter-chk-doc" then
        do:
           run trig-filter-chk-doc  in this-procedure (input v-ref-list,input 0) no-error.
        end.
        when "filter-chk-doc-autotank" then
        do:
          run trig-filter-chk-doc  in this-procedure (input v-ref-list,input 1) no-error.
        end.
        when "filter-chk-gds" then run trig-filter-chk-gds  in this-procedure (input v-ref-list) no-error.
        when "filter-chk-pay" then run trig-filter-chk-pay  in this-procedure (input v-ref-list) no-error.
      END CASE.
      if error-status:error then do:
        run MyEnable in this-procedure.
        return error.
      end.
    END.
  end case.
  if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when 1 then do:
        run proc-b-add in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) no-error  .
      end.
      when 2 then do:
        run proc-b-del in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS ) no-error  .
      end.
      when 3 then do:
        run proc-b-rest in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) no-error  .
      end.
      otherwise do:
        assign
        dsp-rs = "":U.
        run Myenable in this-procedure.
        return error.
      end.
    END CASE.
  end.
  assign
  rs-list-method =  temp-list.fvalue
  .
  find last buf_chk-list-hist no-lock where
            buf_chk-list-hist.id = (v-seq - 1)
      and  buf_chk-list-hist.line = 0 no-error .
  DISPLAY
  (if available buf_chk-list-hist
  then buf_chk-list-hist.des
  else '') @ dsp-rs
  with frame Dialog-Frame.
  if tot-lns = 0 and v-operation = 0 then do:
    run proc-b-add in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) .
  end.
end.
END PROCEDURE.
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable grp-path like ub.goods.grp-name no-undo.
define variable imp-ART like ub.goods.ARTIC no-undo.
define variable scan-qnty as dec no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable v-report-num as integer no-undo .
define variable glog as logical no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable v-oss-code like ub.chk-gds-attr.attr-code no-undo .
define VARIABLE v-oss-type like ub.chk-gds-attr.attr-value no-undo .
define variable v-curr-code like ub.cash-pay.curr-code no-undo .
define variable v-wth-code like ub.wealth.wth-code no-undo .
define variable v-line-num as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-chk-type as character no-undo .
define variable imp-doc-code       as character no-undo .
define variable imp-chk-type       as character no-undo .
define buffer buf_chk-list-hist for chk-list-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_wealth for ub.wealth.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
do
on error undo, return error return-value
:
assign
lns-cnt = 0
lns-ignore = 0
tot-lns = (if line-mode = 'ОСТАВИТЬ':U then 0 else tot-lns)
.
run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame Dialog-Frame = 12.
case rs-list-method:
  WHEN "chk-doc" THEN DO:
    _kk:
    for each buf_chk-list-hist where
             buf_chk-list-hist.id = p-id
        and  buf_chk-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_chk-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first ub.chk-doc no-lock where rowid(ub.chk-doc) = v-rowid.
      run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  WHEN "wth-DOC" THEN DO:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_chk-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first buf_wth-doc no-lock where
                rowid(buf_wth-doc) = v-rowid no-error.
      if available buf_wth-doc then do:
        for each ub.chk-doc No-LOCK WHERE
                 ub.chk-doc.out-code = buf_wth-doc.doc-code :
          run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  WHEN "inkas" THEN DO:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_chk-list-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      find first buf_inkas no-lock where
                rowid(buf_inkas) = v-rowid no-error.
      if available buf_inkas then do:
        for each chk-doc No-LOCK WHERE
                 chk-doc.out-code = buf_inkas.inkas-code :
          run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  END.
  when "d-card" then do:
   _d-card:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-d-card   = entry(1, buf_chk-list-hist.item_, chr(3))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _d-card.
define variable vss-include-info87 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _d-card.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = v-d-card no-error.
      if not avail buf_dis-card then next _d-card.
      CASE entry(1, buf_chk-list-hist.status_, chr(4)):
        when 'все':U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          ASSIGN
          V-START-DATE = DATE(ENTRY(2, buf_chk-list-hist.status_, chr(4)))
          V-END-DATE = DATE(ENTRY(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "goods" then do:
   _gds:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-gds-code   = integer(entry(1, buf_chk-list-hist.item_, chr(3)))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _gds.
define variable vss-include-info88 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _gds.
      find first buf_goods no-lock where
                buf_goods.gds-code = v-gds-code no-error.
      if not avail buf_goods then next _gds.
      for each buf_bar-code no-lock where
              buf_bar-code.gds-code = buf_goods.gds-code,
        each buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code,
        first chk-doc No-LOCK WHERE
                chk-doc.doc-code = buf_chk-gds.doc-code
          AND  chk-doc.obj-type = v-obj-type
          AND  chk-doc.obj-code = v-obj-code:
          run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gds-list" then do:
    _gds-list:
    for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
        and buf_chk-list-hist.item_ <> '':U:
      assign
      f-gds-name = entry(1, buf_chk-list-hist.item_, chr(3))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _gds-list.
define variable vss-include-info89 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _gds-list.
      run gbl/filename.p
                    (input  f-gds-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do: end. else do:
      input stream sout from value (v-full-path).
      repeat while true:
        import stream sout  imp-type imp-code imp-art no-error.
        find first buf_goods no-lock where
                  buf_goods.artic = imp-art
            AND buf_goods.prod-type = imp-type
            AND buf_goods.prod-code = imp-code no-error .
        if avail buf_goods then do:
          _kk:
          for each buf_bar-code no-lock where
                buf_bar-code.gds-code = buf_goods.gds-code,
            each buf_chk-gds no-lock where
                buf_chk-gds.b-code = buf_bar-code.b-code,
            first chk-doc No-LOCK WHERE
                buf_chk-gds.doc-code = chk-doc.doc-code
            AND  chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code:
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      input stream sout close.
    end.
    end.
  end.
  when "cash-pay" then do:
   _cash-pay:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-cdpay-code   = integer(entry(1, buf_chk-list-hist.item_, chr(3)))
      v-curr-code   = integer(entry(2, buf_chk-list-hist.item_, chr(3)))
      v-obj-type = entry(3, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(4, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _cash-pay.
define variable vss-include-info90 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _cash-pay.
      find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = v-cdpay-code
            AND buf_cash-pay.curr-code = v-curr-code no-error.
      if not avail buf_cash-pay then next _cash-pay.
      CASE entry(1, buf_chk-list-hist.STATUS_, chr(4)):
        when 'все':U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.out-code = ?,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
          v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "chk-oss" then do:
   _chk-oss:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-oss-type   = entry(1, buf_chk-list-hist.item_, chr(3))
      v-oss-code   = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-type = entry(3, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(4, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _chk-oss.
define variable vss-include-info91 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _chk-oss.
      find first buf_chk-gds-attr no-lock where
      buf_chk-gds-attr.attr-value = v-oss-code
      and buf_chk-gds-attr.attr-code = "oss-code" no-error.
      if not avail buf_chk-gds-attr then next _chk-oss.
      CASE entry(1, buf_chk-list-hist.STATUS_, chr(4)):
        when 'все':U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.out-code = ?,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
          v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
      end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "wealth" then do:
   _wealth:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-wth-code   = integer(entry(1, buf_chk-list-hist.item_, chr(3)))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _wealth.
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _wealth.
      find first buf_wealth no-lock where
                buf_wealth.wth-code = v-wth-code no-error.
      if not avail buf_wealth then next _wealth.
      CASE entry(1, buf_chk-list-hist.STATUS_, chr(4)):
        when 'все':U then do:
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), '2,3,4,5,7':U) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code
            AND chk-doc.out-code = ? ,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), '2,3,4,5,7':U) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":u then do:
          assign
          v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
          v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code
            AND  chk-doc.chk-date >= v-start-date
            AND  chk-doc.chk-date  <= v-end-date  ,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), '2,3,4,5,7':U) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gds-line-num" then do:
   _gds-line-num:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-line-num   = integer(entry(1, buf_chk-list-hist.item_, chr(3)))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _gds-line-num.
define variable vss-include-info93 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _gds-line-num.
      CASE entry(1, buf_chk-list-hist.STATUS_, chr(4)):
        when 'все':U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = v-line-num then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?            ,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = v-line-num then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
          v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = integer(v-rid-list) then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "chk-type" then do:
   _chk-type:
   for each buf_chk-list-hist where
            buf_chk-list-hist.id = p-id
      and  buf_chk-list-hist.item_ <> '':U:
      assign
      v-chk-type = entry(1, buf_chk-list-hist.item_, chr(3))
      v-obj-type = entry(2, buf_chk-list-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_chk-list-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then  next _chk-type.
define variable vss-include-info94 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _chk-type.
      CASE entry(1, buf_chk-list-hist.STATUS_, chr(4)):
        when 'все':U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
          v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "cpdoc-attr":U then do:
      if v-rid-list = "" then do:
            return error.
        end.
        else do:
        find first buf_chk-list-hist where buf_chk-list-hist.id = p-id.
        for each buf_userobjs_temp-user-obj no-lock :
            for each  ub.chk-pay no-lock
                where ub.chk-pay.obj-type = buf_userobjs_temp-user-obj.obj-type
                and   ub.chk-pay.obj-code = buf_userobjs_temp-user-obj.obj-code :
                    for each  ub.chk-pay-attr no-lock
                        where ub.chk-pay-attr.doc-code  = ub.chk-pay.doc-code
                        and   ub.chk-pay-attr.attr-code = v-rid-list :
                            for each chk-doc no-lock where ub.chk-doc.doc-code = ub.chk-pay.doc-code :
                                run ex-chk in this-procedure ( input rs-list-method,
                                                               input rs-status,
                                                               input line-mode ).
                            end.
                    end.
            end.
        end.
        end.
        assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
        buf_chk-list-hist.num-add  = lns-cnt.
  end.
  when "cpdoc-attr-val":U then do:
      if v-rid-list = "" then do:
            return error.
        end.
        else do:
        find first buf_chk-list-hist where buf_chk-list-hist.id = p-id.
        for each buf_userobjs_temp-user-obj no-lock :
            for each  ub.chk-pay no-lock
                where ub.chk-pay.obj-type = buf_userobjs_temp-user-obj.obj-type
                and   ub.chk-pay.obj-code = buf_userobjs_temp-user-obj.obj-code :
                    for each  ub.chk-pay-attr no-lock
                        where ub.chk-pay-attr.doc-code   = ub.chk-pay.doc-code
                        and   ub.chk-pay-attr.attr-code  = v-rid-list
                        and   ub.chk-pay-attr.attr-value = v-cpdoc-attr-val :
                            for each chk-doc no-lock where ub.chk-doc.doc-code = ub.chk-pay.doc-code :
                                run ex-chk in this-procedure ( input rs-list-method,
                                                               input rs-status,
                                                               input line-mode ).
                            end.
                    end.
            end.
        end.
        end.
        assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
        buf_chk-list-hist.num-add  = lns-cnt.
  end.
  when "file" then do:
    find first buf_chk-list-hist where
              buf_chk-list-hist.id = p-id
          AND buf_chk-list-hist.item_ <> '':U .
    run gbl/filename.p
      (input  buf_chk-list-hist.item_
      ,output v-full-path
      ,output v-path
      ,output v-file-name
      ,output v-file-name-no-ext
      ,output v-file-name-ext
      ) no-error .
      if error-status:error then do: end. else do:
    input stream sout from value (v-full-path).
    repeat:
      import stream sout imp-doc-code imp-chk-type no-error.
      if lookup(string(imp-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U) > 0
      or imp-chk-type = ?
      then do:
        find first chk-doc no-lock where
                  chk-doc.doc-code = imp-doc-code No-error.
        if available chk-doc then run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end.
    end.
    input stream sout close.
    assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "filter-chk-doc"
  or
  when "filter-chk-gds"
  or
  when "filter-chk-pay"
  or
  when "filter-chk-doc-autotank"
  then do:
    define variable v-filter-var as character no-undo .
    _filter:
    for each buf_chk-list-hist where
             buf_chk-list-hist.id = p-id
         AND buf_chk-list-hist.item_ <> '':U .
      if entry(1, buf_chk-list-hist.status_, chr(4)) = "chk-date" then do:
        assign
        v-start-date = date(entry(2, buf_chk-list-hist.status_, chr(4)))
        v-end-date = date(entry(3, buf_chk-list-hist.status_, chr(4)))
        .
      end.
      assign
      v-obj-type = entry(1, buf_chk-list-hist.item, chr(3))
      v-obj-code = integer(entry(2, buf_chk-list-hist.item, chr(3)))
      no-error .
      if error-status:error then next _filter.
      run proc-write-filter-expression-var in this-procedure ( input entry(3, buf_chk-list-hist.item_, chr(3)), output v-filter-var  ).
define variable vss-include-info95 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-object-available
  )  .
      if v-object-available <> true then next _filter.
      CASE rs-list-method:
        when "filter-chk-doc" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input 'chk-doc':U
                        ,input v-filter-var
                        ,input (if RS-STATUS = 'все':U
                              then " true "
                              else (if RS-STATUS = "free":U
                                    then " chk-doc.out-code = ? "
                                    else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                  )
                              )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                        .
        end.
        when "filter-chk-gds" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру товарных строк (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input 'chk-gds':U
                        ,input v-filter-var
                        ,input (if RS-STATUS = 'все':U
                                then " true "
                                else (if RS-STATUS = "free":U
                                      then " chk-doc.out-code = ? "
                                      else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                    )
                                )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                          .
        end.
        when "filter-chk-pay" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру cтрок оплат (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input 'chk-pay':U
                        ,input v-filter-var
                        ,input (if RS-STATUS = 'все':U
                                then " true "
                                else (if RS-STATUS = "free":U
                                      then " chk-doc.out-code = ? "
                                      else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                    )
                                )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                          .
        end.
        when "filter-chk-doc-autotank" then do:
          run gbl/chk-fill.p (input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input 'chk-pay-attr':U
                        ,input v-filter-var
                        ,input (if RS-STATUS = 'все':U
                              then " true "
                              else (if RS-STATUS = "free":U
                                    then " chk-doc.out-code = ? "
                                    else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                  )
                              )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                        .
        end.
      END CASE.
      assign                                                           buf_chk-list-hist.num-add  = lns-cnt - v-num-add                       buf_chk-list-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_chk-list-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_chk-list-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
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
PROCEDURE trig-filter-chk-doc :
define input parameter v-ref-list as character no-undo .
define input parameter p-reg      as integer   no-undo .
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
if p-reg = 0 then
do:
  message
   "Чеки(товарные), выбранные в соответствии с заданным фильтром (без учета сортировки)."
   skip stat-line(CHK-STATUS)
   view-as alert-box question buttons OK-Cancel update glog.
end.
else
do:
  message
   "Чеки(автотанк) в которых есть разн.по запр.за нал, выбранные в соответствии с заданным фильтром (без учета сортировки)."
   skip stat-line(CHK-STATUS)
   view-as alert-box question buttons OK-Cancel update glog.
end.
if not glog then do:
  return error.
end.
if p-reg = 0 then
do:
 assign
   c-point = "chk-list_chk-doc":U + chr(4) + "Список чеков" + chr(4) + "no"
   .
 assign
  tbl = 'chk-doc':U
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
end.
else
do:
 assign
   c-point = "chk-list_chk-doc-autotank":U + chr(4) + "Список чеков" + chr(4) + "no"
   .
 assign
 c-point = "chk-list_chk-doc":U + chr(4) + "Список чеков" + chr(4) + "no"
 .
 assign
  tbl = 'chk-doc':U
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
end .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', 'Код кассира',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', 'Код продавца',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier-psn-code', 'Кассир-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('salesman-psn-code', 'Продавец-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('z-number', 'N Z-отчета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-num', 'N док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-num2', 'N заказа', '',
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
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр чеков"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).
end.
END PROCEDURE.
PROCEDURE trig-filter-chk-gds :
define input parameter v-ref-list as character no-undo .
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
message
"Чеки(товарные) cо строками товара, выбранными в соответствии с заданным фильтром."
skip stat-line(CHK-STATUS)
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "chk-list_chk-gds"  + chr(4) + "Список товарных строк" + chr(4) + "no"
.
assign
  tbl = 'chk-gds'
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('b-code', 'Бар-код в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', 'Дата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('depart-type*depart-code', 'Подразделение(кухня) в БД', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('depart-id', 'ID подразделения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', 'Скидка в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Количество в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-error', 'Ош?', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-num', 'Номер строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-sign', 'Знак строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-type', 'Тип (т или у)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pass-gds', 'Ввод кода (вручную=1 авто=0)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('price-base', 'Цена', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('(pump modulo 1000)', 'Номер ТРК', 'function_integer',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '№ продавца на кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('salesman-psn-code', 'Код продавца в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Исходный бар-код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-discnt', 'Скидка в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-price', 'Цена чека', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-qnty', 'Количество в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-sum', 'Сумма строки в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма строки в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('time-oper', 'Время', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('write-off-code', 'Код списания', '',
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
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр товарных строк"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).
end.
END PROCEDURE.
PROCEDURE trig-filter-chk-pay :
define input parameter v-ref-list as character no-undo .
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
message
"Чеки(товарные) cо строками оплат, выбранными в соответствии с заданным фильтром."
skip stat-line(CHK-STATUS)
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "chk-list_chk-pay"  + chr(4) + "Список строк оплат" + chr(4) + "no"
.
assign
tbl = 'chk-pay'
join-tbl = "":U
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('curr-code', 'Код валюты оплаты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Тип касс.платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-card', '№ платежной карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-rubl', 'Сумма оплаты в нац.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-base', 'Сумма оплаты в б.в.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-sum', 'Сумма оплаты в вал. платежа', '',
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
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр строк оплат"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).
end.
END PROCEDURE.
PROCEDURE trig-filter-create :
define input parameter p-title as character no-undo .
define input parameter p-naim as character no-undo .
define input parameter p-where-ysl as character no-undo .
define input parameter p-where-ysl-rus as character no-undo .
define variable num-rec as integer no-undo .
define variable v-recs as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-bh as handle no-undo  .
define variable v-prev-type as character no-undo .
define variable v-prev-code as integer no-undo .
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-count in this-procedure
  (output v-recs
  )  .
    assign
    v-prev-type = '':U
    v-prev-code = 0
    .
  _do:
  do num-rec = 0 to v-recs:
    if v-recs = 0 then do:
      num-rec = 1 .
    end.
    if num-rec > 0
    or v-recs =  1
    then do:
      find first buf_userobjs_temp-user-obj where
              (buf_userobjs_temp-user-obj.obj-type = v-prev-type
          and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
          or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
      if not available buf_userobjs_temp-user-obj then next _do.
    end.
    if v-recs = 1 then do:
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("&1: &2 &4 &5&6 &6", p-title, p-naim, p-where-ysl-rus, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code, stat-line(CHK-STATUS))
      v-item     =  buf_userobjs_temp-user-obj.obj-type + chr(3) +
                    string(buf_userobjs_temp-user-obj.obj-code ) + chr(3) +
                    ubflt.filter.where-ysl
      v-tbl-name = 'chk-doc':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
    end.
    else do:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        dsp-rs = substitute("&1: &2 &3 &4", p-title, p-naim, p-where-ysl-rus, stat-line(CHK-STATUS))
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
        dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type , buf_userobjs_temp-user-obj.obj-code )
        v-item     =  buf_userobjs_temp-user-obj.obj-type  + chr(3) +
                      string(buf_userobjs_temp-user-obj.obj-code ) + chr(3) +
                      p-where-ysl
         v-tbl-name = 'chk-doc':U
         v-bh       = ?
         v-tot-lns  = tot-lns + num-rec
        .
      end.
    end.
    v-no-hist = (if num-rec = 1 then 0 else num-rec).
    run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-temp-seq
                                        , input v-line
                                        , input '':U
                                        , input dsp-rs
                                        , input v-tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input v-item
                                        , input '':U
                                        , input v-bh
                                        ).
    if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
    if available buf_userobjs_temp-user-obj then
    assign
    v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
    v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
    .
  end.
END PROCEDURE.
PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-chk-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("Чек &1 от &2 &3&4"
                                                          , chk-list.doc-code
                                                          , string(chk-list.chk-date), chk-list.obj-type, chk-list.obj-code)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('chk-doc':U + chr(3) + chk-list.doc-code)
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-chk-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input substitute("Чек &1 от &2 &3&4"
                                                            , chk-list.doc-code
                                                            , string(chk-list.chk-date), chk-list.obj-type, chk-list.obj-code)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('chk-doc':U + chr(3) + chk-list.doc-code)
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-chk-list-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
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
FUNCTION get-chk-type RETURNS CHARACTER
  ( LOC-DOC-CODE AS CHARACTER, loc-chk-type as integer, loc-is-wth as logical ) :
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-str as character no-undo.
CASE loc-is-wth:
    when yes then do:
    assign
    v-str = entry (lookup (string(loc-chk-type),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U)
    no-error
    .
    end.
    when no then do:
      if loc-chk-type = ?
      or loc-chk-type = 0
      then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = loc-doc-code no-error .
        if available buf_chk-doc then do:
          assign
          loc-chk-type = integer(if buf_chk-doc.netto >= 0
                  then '1':U
                  else '6':U)
          .
        end.
      end.
      assign
      v-str = entry (lookup (string(loc-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
      no-error
      .
    end.
END CASE.
  RETURN v-str.
END FUNCTION.
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
DEFINE VARIABLE var-stat-line as character no-undo .
CASE p-status-chr:
  when 'все':U then do:
    assign
    var-stat-line = "(все чеки)"
    .
  end.
  when "free":U then do:
    assign
    var-stat-line = "(неучтенные чеки)"
    .
  end.
  when "chk-date":U then do:
    assign
    var-stat-line = substitute("(чеки с датой с &1 по &2)", v-start-date, v-end-date)
    .
  end.
END CASE.
return var-stat-line .
END.
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first BR-list.
    end.
    when "last":U
    then do:
      get last BR-list.
    end.
    when "prev":U
    then do:
      get prev BR-list.
      if not available chk-list then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next BR-list.
      if not available chk-list then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case .
  find first buf_chk-doc no-lock where buf_chk-doc.doc-code = chk-list.doc-code no-error.
  if available buf_chk-doc then do :
    assign
      p-chk-doc-recid = recid(buf_chk-doc)
    .
  end.
  run reposition-query in this-procedure
    (input    recid(chk-list)
    ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition BR-list to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse BR-list .
    apply "VALUE-CHANGED":u to browse BR-list .
  end.
END PROCEDURE.
