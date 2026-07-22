block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-profile-id as integer   no-undo .
define input  parameter p-codex-id as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define input  parameter p-db-num like ub.db.db-num no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-save        as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: edocrum.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/edocrum.p $":u .
define variable vss-description as character no-undo init "Вызов процедур RUM для обработки операции электронного документооборота" .
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u
                              ,p-process
                              ,p-db-num
                              ,p-doc-code
                              )
    .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table temp-pers-proc no-undo
field proc-name as character
field vproc-handle as handle
field vparent-handle as handle
field user-name as character
field id as integer
field vpar as character
field rank-to-delete as integer
index pi is unique primary
proc-name
id
index puser
proc-name
user-name
index ppar
proc-name
vpar
index iparent
vparent-handle
proc-name
index iid
id
index ird
rank-to-delete
.
define variable v-per-proc-num as integer no-undo .
procedure perproc-create-proc :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define input  parameter p-proc-handle  as handle no-undo .
define input  parameter p-run        as logical no-undo .
define input  parameter p-parameter as character no-undo .
define input  parameter p-userid as character no-undo .
define input  parameter p-rank-to-delete as integer no-undo .
define output parameter p-id as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-proc-handle as handle no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
define buffer buf0_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    if v-per-proc-num > 100 then return error '>'.
    find first buf0_temp-pers-proc no-lock where
              buf0_temp-pers-proc.proc-name = p-proc-name use-index pi    no-error.
    if not available buf0_temp-pers-proc then do:
      if p-run then do:
        run value(p-proc-name) persistent SET v-proc-handle (input p-parameter) no-error.
        if error-status :error then undo, return error return-value .
      end.
      else v-proc-handle = p-proc-handle.
      find last buf0_temp-pers-proc no-lock use-index iid  no-error.
      create buf_temp-pers-proc.
      assign
      buf_temp-pers-proc.proc-name = p-proc-name
      buf_temp-pers-proc.id = (if not available buf0_temp-pers-proc
                                then  0
                                else buf0_temp-pers-proc.id + 1)
      buf_temp-pers-proc.user-name = p-userid
      buf_temp-pers-proc.vpar      = p-parameter
      buf_temp-pers-proc.vparent-handle = p-parent-handle
      buf_temp-pers-proc.vproc-handle = v-proc-handle
      buf_temp-pers-proc.rank-to-delete = p-rank-to-delete
      p-id = buf_temp-pers-proc.id
      v-per-proc-num = v-per-proc-num + 1
      .
    end.
    else p-id = buf0_temp-pers-proc.id.
  end.
end procedure.
procedure perproc-delete-proc-user :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-user-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.user-name = p-user-name:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-proc-id :
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
        buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-by-rank :
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    for each buf_temp-pers-proc where
    by buf_temp-pers-proc.rank-to-delete:
      APPLY "delete" to buf_temp-pers-proc.vproc-handle.
      delete procedure buf_temp-pers-proc.vproc-handle.
      delete buf_temp-pers-proc.
      v-per-proc-num = v-per-proc-num - 1.
    end.
  end.
end procedure.
procedure perproc-delete-proc-name-id :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-par :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-parameter as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.vpar      = p-parameter:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-from-parent :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     if p-proc-name = "":u then do:
      for each buf_temp-pers-proc where
         buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
     end.
     else do:
      for each buf_temp-pers-proc where
              buf_temp-pers-proc.proc-name = p-proc-name
        AND  buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-param-name no-undo
field profile_id as integer
field profile-type as character
field schema-name as character
field esys-id as integer
field call_id as character
field once-more as integer
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field param-name as character
field param-type as character
field pack-process-uniq-key-rec as character
index pi is primary unique
esys-id
schema-name
profile_id
call_id
.
procedure xmlischn_fill :
define input  parameter p-codex-id  as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define buffer buf_rule-call-param  for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_temp-param-name for temp-param-name.
define variable v-esys-id-list as character no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_rule-call-param where
            buf_rule-call-param.codex_id = p-codex-id
        and buf_rule-call-param.ruleset_id = p-ruleset-id
    break
    by buf_rule-call-param.call_id
    by buf_rule-call-param.profile_id
    by buf_rule-call-param.once-more
    :
      if first-of(buf_rule-call-param.once-more) then do:
        v-esys-id-list = ''.
        for each buf2_rule-call-param no-lock
           where buf2_rule-call-param.call_id    = buf_rule-call-param.call_id
             and buf2_rule-call-param.codex_id   = buf_rule-call-param.codex_id
             and buf2_rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
             and buf2_rule-call-param.profile_id = buf_rule-call-param.profile_id
             and buf2_rule-call-param.once-more  = buf_rule-call-param.once-more
             and buf2_rule-call-param.param-2-data-type = 'ext-system':U :
          if buf2_rule-call-param.param-name = "p-esys-id"
               or
               (buf2_rule-call-param.param-name = "p-esys-id-list"
               and
               buf2_rule-call-param.p-index > 0)
          then do:
            assign
            v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else chr(44)) +
                            string( buf2_rule-call-param.param-value-integer)
            .
          end.
        end.
      end.
      if v-esys-id-list = "" then v-esys-id-list = "-1".
      if buf_rule-call-param.param-2-data-type = "xsd" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
          create buf_temp-param-name.
          assign
          buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          buf_temp-param-name.call_id = buf_rule-call-param.call_id
          buf_temp-param-name.once-more = buf_rule-call-param.once-more
          buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
          buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
          buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
          buf_temp-param-name.order_id = buf_rule-call-param.order_id
          buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "xsd"
            buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
            buf_temp-param-name.pack-process-uniq-key-rec =
            substitute("&2&1&3&1&4&1&5"
                                                                      , chr(4)
                                                                      , buf_rule-call-param.call_id
                                                                      , buf_rule-call-param.codex_id
                                                                      , buf_rule-call-param.ruleset_id
                                                                      , buf_rule-call-param.order_id)
            .
            end.
          end.
        end.
      end.
      if buf_rule-call-param.param-2-data-type = "sub-type" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
            create buf_temp-param-name.
            assign
            buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
            buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
            buf_temp-param-name.call_id = buf_rule-call-param.call_id
            buf_temp-param-name.once-more = buf_rule-call-param.once-more
            buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
            buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
            buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
            buf_temp-param-name.order_id = buf_rule-call-param.order_id
            buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "no-xsd"
          buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
          buf_temp-param-name.pack-process-uniq-key-rec =
          substitute("&2&1&3&1&4&1&5"
                                                                     , chr(4)
                                                                     , buf_rule-call-param.call_id
                                                                     , buf_rule-call-param.codex_id
                                                                     , buf_rule-call-param.ruleset_id
                                                                     , buf_rule-call-param.order_id)
          .
        end.
      end.
    end.
    end.
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table ord-list no-undo
field host-code  like ub.ord-doc.host-code
field cli-type   like ub.ord-doc.cli-type
field cli-code   like ub.ord-doc.cli-code
field doc-date   like ub.ord-doc.doc-date
field doc-code   like ub.ord-doc.doc-code
field obj-type   like ub.ord-doc.obj-type
field obj-code   like ub.ord-doc.obj-code
field fact-num   like ub.ord-doc.fact-num
field fact-date  like ub.ord-doc.fact-date
field shift-date like ub.ord-doc.shift-date
field shift-num  like ub.ord-doc.shift-num
field shift-name like ub.ord-doc.shift-name
field ord-int1   like ub.ord-doc.ord-int1
field cli-out-doc like ub.ord-doc.cli-out-doc
field ship-date  like ub.ord-doc.ship-date
field ship-time  like ub.ord-doc.ship-time
field status_    as character
field trn-doc    as character
field fact-order as decimal
field is-trn-doc as logical
field doc-type   like ub.ord-doc.doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field ps         as character
field dm         as integer
field charkey_one as character
index xpk is primary unique doc-code doc-type trn-doc
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
.
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table doc-list no-undo
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table doc-list-hist no-undo
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-stop-leave-status as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command  as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-id as integer no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-proc-name as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleset-id-list as character no-undo extent 3.
define variable v-codex-id as integer no-undo .
define variable v-codex-in-db as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable sign as integer no-undo .
define variable v-codex-id-list as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-calc-chr as character no-undo .
define variable v-can-run as logical no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-profile-id as integer no-undo .
define variable log-file-name as character no-undo init "process-cli-list.txt".
define variable v-save-int as integer no-undo .
define variable v-charkey_one as character no-undo .
define variable v-charkey_one-2 as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-is-empty as logical no-undo .
define variable v-rec-ord_ as integer no-undo .
define variable v-param-name as character no-undo .
define variable v-xsd-file as character no-undo .
define variable v-cont-handle as handle no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-pers-proc  for temp-pers-proc.
define buffer buf_db for ub.db.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_inkas for ub.inkas.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-cmd no-undo
field cmd-code as integer
field db-list as character
index pi is unique primary
db-list
index icmd
cmd-code
.
define NEW SHARED temp-table temp-smart-route no-undo
field key-field as character
field db-num as integer
index pi is unique primary
key-field
db-num
.
define NEW SHARED temp-table temp-no-route no-undo
field rec-ord as integer
field db-num as integer
index pi is unique primary
db-num
rec-ord
index iro
rec-ord
.
define NEW SHARED temp-table temp-smart-link no-undo
field uniq-key-rec as character
field key-field as character
field rec-ord as integer
field is-smart as logical
index pi is unique primary
key-field
uniq-key-rec
rec-ord
index iu
uniq-key-rec
index iro
rec-ord
.
define NEW SHARED temp-table temp-nws-outline no-undo
like ub.nws-outline.
procedure create-smart-route :
define input parameter p-key-field as character no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error
  :
    find first buf_temp-smart-route where
              buf_temp-smart-route.key-field = p-key-field
          and buf_temp-smart-route.db-num = p-db-num no-error.
    if not available buf_temp-smart-route then do:
      create buf_temp-smart-route.
      assign
      buf_temp-smart-route.key-field = p-key-field
      buf_temp-smart-route.db-num = p-db-num
      .
    end.
  end.
end procedure.
procedure create-smart-route-link :
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define input parameter p-key-field as character no-undo .
define input parameter p-rec-ord as integer no-undo .
define input parameter p-is-smart as logical no-undo .
define variable v-key-rec as character no-undo .
define buffer buf_temp-smart-link for temp-smart-link.
  do
  on error undo, return error
  :
    run gen-key-rec in this-procedure ( input p-tbl-name
                                       ,input p-bh_tbl-name
                                       ,output v-key-rec     ).
   find first buf_temp-smart-link where
              buf_temp-smart-link.uniq-key-rec = v-key-rec
           and buf_temp-smart-link.key-field = p-key-field
           and buf_temp-smart-link.rec-ord = p-rec-ord
           no-error .
   if not available buf_temp-smart-link then do:
     create buf_temp-smart-link.
     assign
     buf_temp-smart-link.uniq-key-rec = v-key-rec
     buf_temp-smart-link.key-field = p-key-field
     buf_temp-smart-link.rec-ord = p-rec-ord
     buf_temp-smart-link.is-smart = p-is-smart
     .
   end.
  end.
end procedure.
procedure create-nws-outline :
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define input parameter p-outline-type as character no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-charkey_two as character no-undo .
define input parameter p-charkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .
define variable v-no-id as integer no-undo .
define variable v-rec-ord as integer no-undo .
  do
  on error undo, return error return-value
  :
    find last temp-nws-outline use-index pi no-error .
    v-no-id = (if available temp-nws-outline
               then (temp-nws-outline.no-id  + 1)
               else 1).
    create temp-nws-outline.
    assign
    temp-nws-outline.charkeY_one = p-charkey_one
    temp-nws-outline.charkeY_two = p-charkey_two
    temp-nws-outline.charkeY_three = p-charkey_three
    temp-nws-outline.key#_one = p-key#_one
    temp-nws-outline.key#_two = p-key#_two
    temp-nws-outline.key#_three = p-key#_three
    temp-nws-outline.no-id = v-no-id
    temp-nws-outline.outline-type = p-outline-type
    .
                                run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'nws-outline':U                                                                                          ,input '+update'                                                                                         ,input (buffer temp-nws-outline:handle)                                                                                    ,input ''                                                                                         ,output v-rec-ord                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'nws-outline':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run  create-smart-route in this-procedure (
                                                input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                               ,input -1).
    run create-smart-route-link in this-procedure (
                                                   input 'nws-outline':U
                                                  ,input (buffer temp-nws-outline:handle)
                                                  ,input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                                  ,input v-rec-ord
                                                  ,input no
                                                  ).
  end.
end procedure.
procedure create-no-route :
define input parameter p-rec-ord as integer no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
do
on error undo, return error
:
   find first buf_temp-no-route where
              buf_temp-no-route.rec-ord = p-rec-ord
           and buf_temp-no-route.db-num = p-db-num no-error .
   if not available buf_temp-no-route then do:
     create buf_temp-no-route.
     assign
     buf_temp-no-route.rec-ord = p-rec-ord
     buf_temp-no-route.db-num = p-db-num
     .
   end.
end.
end procedure.
procedure clear-from-rec-ord :
define input parameter p-rec-ord as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
define buffer buf_temp-smart-link for temp-smart-link.
do
on error undo, return error
:
for each buf_temp-no-route where
        buf_temp-no-route.rec-ord > p-rec-ord:
  delete buf_temp-no-route.
end.
for each buf_temp-smart-link where
        buf_temp-smart-link.rec-ord > p-rec-ord:
   delete buf_temp-smart-link.
end.
end.
end procedure.
define buffer buf_temp-cmd  for temp-cmd.
define buffer buf1_temp-cmd  for temp-cmd.
define buffer buf_temp-smart-route  for temp-smart-route.
define buffer buf_temp-smart-link  for temp-smart-link.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-no-route for temp-no-route.
if transaction
and (p-process =  'xml-esys-import_order':U
    or
    p-process = 'xml-esys-import_rcv':U
    or
    p-process = 'xml-esys-import_price-doc':U
    or
    p-process = 'xml-esys-import_trn-doc':U
    or
    p-process = 'xml-esys-import_inv-doc':U
    or
    p-process = 'xml-esys-import_contract':U
    or
    p-process = 'text-import_specif':U
    or
    p-process = 'excel-import_specif':U
    )
then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Вызов процедуры в действующей транзакции недопустим") skip
    view-as alert-box error .
  return error substitute( "&1. Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .
end.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if not p-save
        then do:
    message
    substitute("Неверное значение параметра p-save = &1,&2" +
               "в ситуации когда p-process = &3"
               , p-save
               , chr(10)
               , p-process)
    view-as alert-box error .
    undo _main, return error .
  end.
  v-save-int = (if p-save
                then 0
                else -1).
  CASE p-process:
    when 'batchwork-export_order':U
    then do:
      if not g#auto then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code.
        create ord-list.
        buffer-copy buf_ord-doc to ord-list
        assign
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'batchwork-routing_order':U
    then do:
      if not g#auto then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code.
        create ord-list.
        buffer-copy buf_ord-doc to ord-list
        assign
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'xml-file-import_order':U
    then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id) + chr(44) + string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = string(1)
      .
    end.
    when 'batchwork-routing_price-doc':U
    then do:
      if not g#auto then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_price-doc exclusive-lock where
                  buf_price-doc.doc-num = v-doc-code.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_price-doc.doc-num
    and doc-list.doc-type = 'переоценка':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_price-doc.doc-num
  doc-list.obj-type   = buf_price-doc.obj-type
  doc-list.obj-code   = buf_price-doc.obj-code
  doc-list.fact-num   = buf_price-doc.fact-num
  doc-list.fact-date  = buf_price-doc.fact-date
  doc-list.shift-date = buf_price-doc.shift-date
  doc-list.shift-num  = buf_price-doc.shift-num
  doc-list.fact-order = buf_price-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'переоценка':U
  doc-list.ext-doc-type   = 'ot':U
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'batchwork-routing_trn-doc':U  then do:
      if not g#auto then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_trn-doc exclusive-lock where
                  buf_trn-doc.doc-code = v-doc-code.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_trn-doc.doc-code
    and doc-list.doc-type = buf_trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_trn-doc.doc-code
  doc-list.obj-type   = buf_trn-doc.obj-type
  doc-list.obj-code   = buf_trn-doc.obj-code
  doc-list.fact-num   = buf_trn-doc.fact-num
  doc-list.doc-date   = buf_trn-doc.doc-date
  doc-list.fact-date  = buf_trn-doc.fact-date
  doc-list.shift-date = buf_trn-doc.shift-date
  doc-list.shift-num  = buf_trn-doc.shift-num
  doc-list.fact-order = buf_trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = buf_trn-doc.doc-type
  doc-list.ext-doc-type   = buf_trn-doc.ext-doc-type
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'batchwork-routing_inkas':U then do:
      if not g#auto then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_inkas exclusive-lock where
                  buf_inkas.inkas-code = v-doc-code.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = buf_inkas.inkas-code
  and doc-list.doc-type = 'касс':U
  no-error .
find first inkas_trn-doc where
           inkas_trn-doc.doc-code = buf_inkas.inkas-code no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  create doc-list .
  assign
  doc-list.doc-code   = buf_inkas.inkas-code
  doc-list.obj-type   = buf_inkas.obj-type
  doc-list.obj-code   = buf_inkas.obj-code
  doc-list.fact-num   = inkas_trn-doc.fact-num
  doc-list.fact-date  = buf_inkas.fact-date
  doc-list.shift-date = buf_inkas.shift-date
  doc-list.shift-num  = buf_inkas.shift-num
  doc-list.fact-order = inkas_trn-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'касс':U
  doc-list.ext-doc-type   = 'касс':U
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'xml-esys-import_order':U
    or
    when 'xml-esys-import_rcv':U
    or
    when 'xml-esys-import_price-doc':U
    or
    when 'xml-esys-import_trn-doc':U
    or
    when 'xml-esys-import_inv-doc':U
    or
    when 'xml-esys-import_contract':U
    then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4)) +
                              chr(4) + entry(3, p-doc-code, chr(4))
                              + chr(4) + entry(4, p-doc-code, chr(4))
                              + chr(4) + entry(5, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      v-cont-handle = p-parent-handle
      v-param-name = entry(6, p-doc-code, chr(4))
      v-xsd-file = entry(7, p-doc-code, chr(4))
      .
      assign
      v-codex-id-list = string(p-codex-id) + (if p-process = 'xml-esys-import_order':U
                                              then (chr(44) + string(p-codex-id))
                                              else '')
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = (if p-process = 'xml-esys-import_order':U
                              then string(2)
                              else '')
      .
    end.
    when 'batchwork-export_rcv':U
    then do:
      if not g#auto then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
      find first buf_trn-doc where
                buf_trn-doc.doc-code = v-doc-code.
        create ord-list.
        find first buf_ord-chain   no-lock where
            buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
            buf_ord-chain.rel-doc-type = "trn" and
            buf_ord-chain.doc-type = "rcv" no-error .
            if error-status :error then return .
        find first buf_ord-doc-rcv no-lock where
                  buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
        if error-status :error then return .
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
        if error-status :error then return .
        assign
        ord-list.trn-doc    = entry (1,buf_ord-doc-rcv.sub-par,chr(4))
        ord-list.host-code  = buf_ord-doc-rcv.host-code
        ord-list.cli-type   = buf_ord-doc-rcv.cli-type
        ord-list.cli-code   = buf_ord-doc-rcv.cli-code
        ord-list.doc-date   = buf_trn-doc.doc-date
        ord-list.doc-code   = buf_ord-doc-rcv.doc-code
        ord-list.obj-type   = buf_ord-doc-rcv.obj-type
        ord-list.obj-code   = buf_ord-doc-rcv.obj-code
        ord-list.fact-num   = buf_trn-doc.fact-num
        ord-list.fact-date  = buf_trn-doc.fact-date
        ord-list.shift-date = buf_trn-doc.shift-date
        ord-list.shift-num  = buf_trn-doc.shift-num
        ord-list.shift-name = buf_trn-doc.shift-name
        ord-list.fact-order = buf_trn-doc.fact-order
        ord-list.cli-out-doc = buf_ord-doc.cli-out-doc
        ord-list.is-trn-doc = true
        ord-list.doc-type   = buf_trn-doc.doc-code
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'batchwork-routing_rcv':U
    then do:
      if not g#auto then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      find first buf_trn-doc where
                buf_trn-doc.doc-code = v-doc-code.
      create ord-list.
      find first buf_ord-chain   no-lock where
          buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
          buf_ord-chain.rel-doc-type = "trn" and
          buf_ord-chain.doc-type = "rcv" no-error .
          if error-status :error then return .
      find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
      if error-status :error then return .
      find first buf_ord-doc no-lock where
                buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
      if error-status :error then return .
      assign
      ord-list.trn-doc    = entry (1,buf_ord-doc-rcv.sub-par,chr(4))
      ord-list.host-code  = buf_ord-doc-rcv.host-code
      ord-list.cli-type   = buf_ord-doc-rcv.cli-type
      ord-list.cli-code   = buf_ord-doc-rcv.cli-code
      ord-list.doc-date   = buf_trn-doc.doc-date
      ord-list.doc-code   = buf_ord-doc-rcv.doc-code
      ord-list.obj-type   = buf_ord-doc-rcv.obj-type
      ord-list.obj-code   = buf_ord-doc-rcv.obj-code
      ord-list.fact-num   = buf_trn-doc.fact-num
      ord-list.fact-date  = buf_trn-doc.fact-date
      ord-list.shift-date = buf_trn-doc.shift-date
      ord-list.shift-num  = buf_trn-doc.shift-num
      ord-list.shift-name = buf_trn-doc.shift-name
      ord-list.fact-order = buf_trn-doc.fact-order
      ord-list.is-trn-doc = true
      ord-list.doc-type   = buf_trn-doc.doc-code
      ord-list.cli-out-doc = buf_ord-doc.cli-out-doc
      ord-list.dm = buf_ord-doc.whole-send-news
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when 'text-import_specif':U
    or
    when 'excel-import_specif':U
    or
    when 'text-export_specif':U
    or
    when 'excel-export_specif':U
    then do:
      if not g#auto then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, chr(4))
      v-process-file-name =  entry(2, p-doc-code, chr(4))
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры edocrum.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,p-process
                                           ).
    end.
  END CASE.
  _codex:
  do v-jj = 1 to num-entries(v-codex-id-list):
    if entry(v-jj, v-codex-id-list) = '':U then next _codex.
    v-codex-id = integer(entry(v-jj, v-codex-id-list)).
    do v-ii = 1 to num-entries(v-ruleset-id-list[v-jj]):
        if entry(v-ii, v-ruleset-id-list[v-jj]) = '':U then next.
        v-ruleset-id = integer(entry(v-ii, v-ruleset-id-list[v-jj])).
      _rule-by-call:
      for each buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = p-uniq-key-rec
          and buf_rule-by-call.can-calc = yes
          and buf_rule-by-call.codex_id = v-codex-id
          and buf_rule-by-call.ruleset_id = v-ruleset-id
      by buf_rule-by-call.call_Id
      by buf_rule-by-call.codex_id
      by buf_rule-by-call.ruleset_id
      by buf_rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
        if p-process = 'batchwork-routing_order':U
        or p-process = 'batchwork-export_order':U
        or p-process = 'xml-file-import_order':U
        or p-process = 'batchwork-routing_rcv':U
        or p-process = 'batchwork-export_rcv':U
        or p-process = 'xml-file-import_rcv':U
        or p-process = 'batchwork-routing_price-doc':U
        or p-process = 'batchwork-routing_inkas':U
        or p-process = 'batchwork-routing_trn-doc':U
        or p-process = 'text-import_specif':U
        or p-process = 'excel-import_specif':U
        or p-process = 'text-export_specif':U
        or p-process = 'excel-export_specif':U
        then do:
          if buf_rule-by-call.profile_id <> v-profile-id then next _rule-by-call.
        end.
        if  (p-process =  'xml-esys-import_order':U
          or
          p-process = 'xml-esys-import_rcv':U
          or
          p-process = 'xml-esys-import_price-doc':U
          or
          p-process = 'xml-esys-import_trn-doc':U
          )
        then do:
          find first buf_rule-call-param no-lock where
                    buf_rule-call-param.call_id = buf_rule-by-call.call_id
                and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
                and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
                and buf_rule-call-param.order_id = buf_rule-by-call.order_id
                and buf_rule-call-param.param-name = v-param-name
                and buf_rule-call-param.param-value-character = v-xsd-file no-error.
          if not available buf_rule-call-param then next _rule-by-call.
        end.
        v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
        run value(v-proc-name)  (
                                                              input parparentproc
                                                            ,input this-procedure:handle
                                                            ,input p-log-handle
                                                            ,input v-cont-handle
                                                            ,input v-codex-id
                                                            ,input v-ruleset-id
                                                            ,input buf_rule-by-call.call_id
                                                            ,input buf_rule-by-call.order_id
                                                            ,input buf_rule-by-call.rule_id
                                                            ,input buf_rule-by-call.profile
                                                            ,input buf_rule-by-call.is_dynamic
                                                            ,input v-doc-type
                                                            ,input v-host-code
                                                            ,input v-obj-type
                                                            ,input v-obj-code
                                                            ,input v-doc-code
                                                            ,input v-process-file-name
                                                            ,input v-save-int
                                                            ,input v-curr-r-b
                                                            ,input v-cmd-proc-handle
                                                            ,input 0
                                                            ) no-error .
        if error-status:error
        then do:
          undo _main, return error substitute("&1&2Ошибка при обработке электронных документов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,chr(10)
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end.
        if v-stop-leave-status > '' then do:
          undo _main, return error substitute("&1&2Процесс обработки электронных документов прерван&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,chr(10)
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end.
      end.
    end.
  end.
end.
procedure set-num-rec :
define input parameter p-num-rec as integer no-undo .
define input parameter p-num-rec-calc-err as integer no-undo .
define input parameter p-num-rec-value-err as integer no-undo .
define input parameter p-num-rec-ok as integer no-undo .
define input parameter p-display as logical no-undo .
define variable v-ok as logical no-undo .
do
on error undo, return error
:
  if not (p-process = 'batch-card-recalc':U) then do:
    return.
  end.
  run set-num-rec in p-parent-handle ( input p-num-rec
                                      ,input p-num-rec-calc-err
                                      ,input p-num-rec-value-err
                                      ,input p-num-rec-ok
                                      ,buffer buf_rule-by-call
                                      ,input p-display
                                      ).
end.
end procedure.
procedure set-stop-leave-status :
define input parameter p-stop-leave-status as character no-undo .
do
on error undo, return error
:
  assign
  v-stop-leave-status = p-stop-leave-status.
end.
end procedure.
