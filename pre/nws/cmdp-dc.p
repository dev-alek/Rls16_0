block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .
define input  parameter p-step     as integer   no-undo .
define input  parameter p-source-db-num as integer no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-cmd-doc-code as character no-undo .
define input  parameter p-cmd-doc-type as character no-undo .
define input  parameter p-ext-doc-type as character no-undo .
define input  parameter p-doc-date as date no-undo .
define input  parameter p-fact-date as date no-undo .
define input  parameter p-sign     as integer no-undo .
define input  parameter cre-pay    as integer no-undo .
define input  parameter p-cmd-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 8f531171ff56, 1872, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Thu May 16 15:50:49 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdp-dc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdp-dc.p $":U .
define variable vss-description as character no-undo init "Обработка команды изменения данных по ДК по документу".
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
      p-vss-parameters = substitute('&1|&2|&3':u,p-counter)
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
def shared temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info6 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info6, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info6, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info6 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info6, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info6, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info6, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info6, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info6, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info6, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info6, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-d-card no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE vchk-pay NO-UNDO
FIELD d-card like ub.chk-doc.d-card
FIELD PAY-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD doc-date like ub.chk-pay.chk-date
FIELD cre-pay as logical
FIELD exch-rate as decimal
FIELD base-rate as decimal
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD tot-base like ub.chk-pay.tot-base
FIELD tot-rubl like ub.chk-pay.tot-rubl
FIELD pmnt-code like ub.payment.pmnt-code
field obj-type            like ub.clients.obj-type
field obj-code            like ub.clients.obj-code
INDEX PI IS PRIMARY UNIQUE
d-card pay-code curr-code doc-date cre-pay exch-rate base-rate
index iobj obj-type obj-code
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info13 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info13 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info13 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            assign
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define shared temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define shared temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define buffer buf_temp-d-card for temp-d-card.
def var vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-cmd-proc-handle as handle no-undo .
define variable p-doc-type as character no-undo .
define variable p-doc-code as character no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define temp-table temp-dis-obj no-undo like ub.dis-obj.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-dis-obj  for temp-dis-obj.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dis-objh_write-dis-obj-rul :
define parameter buffer buf_dis-obj for ub.dis-obj .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if not available buf_dis-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-obj':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-obj':U
    buf_temp-hist-nws-option.key#_one = p-dtm-code
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-obj.
  buffer-copy buf_dis-obj to buf_c-dis-obj
  assign
  buf_c-dis-obj.d-card             = buf_dis-obj.d-card
  buf_c-dis-obj.obj-type           = buf_dis-obj.obj-type
  buf_c-dis-obj.obj-code           = buf_dis-obj.obj-code
  buf_c-dis-obj.card-num           = buf_dis-obj.card-num
  buf_c-dis-obj.dt-code            = buf_dis-obj.dt-code
  buf_c-dis-obj.main-card          = buf_dis-obj.main-card
  buf_c-dis-obj.first-main-card    = buf_dis-obj.first-main-card
  buf_c-dis-obj.first-card         = buf_dis-obj.first-card
  buf_c-dis-obj.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-obj.corr-time          = v-time
  buf_c-dis-obj.corr-user-db-num   = g#db-num
  buf_c-dis-obj.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                      )
  buf_c-dis-obj.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-obj to buf_c-dc-hist
  assign
  buf_c-dc-hist.action = p-action
  buf_c-dc-hist.subject = 'dis-obj':U
  buf_c-dc-hist.host-code =  buf_dis-obj.host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dis-obj':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-obj:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-obj':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
     case  buf_temp-hist-nws-option.smart-nws :
        when integer('0':U)
        or
        when integer('10':U)
        then do:
          run get-db-list-for-d-card  in this-procedure ( input buf_dis-obj.d-card).
          run create-smart-route-link in this-procedure ( input 'c-dis-obj':U
                                                      ,input buffer buf_c-dis-obj:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord2
                                                      ,input yes
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord3
                                                      ,input yes
                                                      ).
        end.
        when integer('1':U) then do:
        end.
        otherwise do:
          run create-smart-route-link in this-procedure ( input 'c-dis-obj':U
                                                      ,input buffer buf_c-dis-obj:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord2
                                                      ,input no
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord3
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-obj.d-card
                                                  ,input -1).
        end.
      end case.
    end.
  end.
end.
end procedure.
procedure dis-objh_send-dis-obj-rul :
define parameter buffer buf_dis-obj for ub.dis-obj .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if not available buf_dis-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-obj':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0  no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-obj':U
    buf_temp-hist-nws-option.key#_one = p-dtm-code
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'dis-obj':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-obj:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-obj':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  if g#db-num = 0 then do:
   case buf_temp-hist-nws-option.smart-nws:
      when integer('0':U)
      or
      when integer('10':U) then do:
        run get-db-list-for-d-card  in this-procedure ( input buf_dis-obj.d-card).
        run create-smart-route-link in this-procedure ( input 'dis-obj':U
                                                    ,input buffer buf_dis-obj:handle
                                                    ,input buf_dis-obj.d-card
                                                    ,input v-rec-ord1
                                                    ,input yes
                                                    ).
      end.
      when integer('1':U) then do:
      end.
      otherwise do:
        run create-smart-route-link in this-procedure ( input 'dis-obj':U
                                                    ,input buffer buf_dis-obj:handle
                                                    ,input buf_dis-obj.d-card
                                                    ,input v-rec-ord1
                                                    ,input no
                                                    ).
        run create-smart-route in this-procedure  ( input buf_dis-obj.d-card
                                                  ,input -1).
      end.
    end case.
    if g#news then do:
      run create-no-route in this-procedure ( input v-rec-ord1
                                             ,input g#news-source-db).
    end.
  end.
end.
end procedure.
procedure get-db-list-for-d-card:
define input parameter p-d-card as character no-undo .
define variable v-current-db-processed as logical no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error return-value
  :
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = p-d-card,
       first buf_clients no-lock where
            buf_clients.obj-type = buf_dis-obj.obj-type
        and buf_clients.obj-code = buf_dis-obj.obj-code
    break by
    buf_clients.db-num:
      if first-of(buf_Clients.db-num) then do:
        find first buf_temp-smart-route no-lock where
              buf_temp-smart-route.key-field = p-d-card
          and buf_temp-smart-route.db-num = buf_clients.db-num
              no-error.
        if available buf_temp-smart-route then return.
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = buf_clients.db-num
        .
        if buf_clients.db-num = g#db-num then do:
          v-current-db-processed = yes.
        end.
      end.
    end.
    if not v-current-db-processed then do:
      find first buf_temp-smart-route no-lock where
            buf_temp-smart-route.key-field = p-d-card
        and buf_temp-smart-route.db-num = g#db-num  no-error.
      if not available buf_temp-smart-route then do:
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = g#db-num
        .
      end.
    end.
  end.
end procedure.
define temp-table temp-dis-host no-undo like ub.dis-host.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_temp-dis-host  for temp-dis-host.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dis-hsth_write-dis-host-rul :
define parameter buffer buf_dis-host for ub.dis-host .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if not available buf_dis-host then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-host':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-host':U
    buf_temp-hist-nws-option.key#_one = p-dtm-code
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-host.
  buffer-copy buf_dis-host to buf_c-dis-host
  assign
  buf_c-dis-host.d-card             = buf_dis-host.d-card
  buf_c-dis-host.host-code          = buf_dis-host.host-code
  buf_c-dis-host.card-num           = buf_dis-host.card-num
  buf_c-dis-host.dt-code            = buf_dis-host.dt-code
  buf_c-dis-host.main-card          = buf_dis-host.main-card
  buf_c-dis-host.first-main-card    = buf_dis-host.first-main-card
  buf_c-dis-host.first-card         = buf_dis-host.first-card
  buf_c-dis-host.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-host.corr-time          = v-time
  buf_c-dis-host.corr-user-db-num   = g#db-num
  buf_c-dis-host.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                      )
  buf_c-dis-host.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-host to buf_c-dc-hist
  assign
  buf_c-dc-hist.action = p-action
  buf_c-dc-hist.subject = 'dis-host':U
  buf_c-dc-hist.host-code =  buf_dis-host.host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
  and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dis-host':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-host:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-host':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      case  buf_temp-hist-nws-option.smart-nws :
        when integer('0':U)
        or
        when integer('10':U)
        then do:
         if buf_dis-host.dt-code = 0
          and buf_dis-host.host-code  = 0
          and buf_Dis-host.whole-send-news = integer('-1':U) then do:
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input no
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input no
                                                        ).
            run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                      ,input -1).
          end.
          else do:
            run get-db-list-for-d-card2  in this-procedure ( input buf_dis-host.d-card).
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input yes
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input yes
                                                        ).
          end.
        end.
        when integer('1':U) then do:
         if buf_dis-host.dt-code = 0
          and buf_dis-host.host-code  = 0
          and buf_Dis-host.whole-send-news = integer('-1':U) then do:
            run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                        ,input buffer buf_c-dis-host:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord2
                                                        ,input no
                                                        ).
            run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                        ,input buffer buf_c-dc-hist:handle
                                                        ,input buf_dis-host.d-card
                                                        ,input v-rec-ord3
                                                        ,input no
                                                        ).
            run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                      ,input -1).
          end.
        end.
        otherwise do:
          run create-smart-route-link in this-procedure ( input 'c-dis-host':U
                                                      ,input buffer buf_c-dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord2
                                                      ,input no
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord3
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
      end case.
    end.
  end.
end.
end procedure.
procedure dis-hsth_send-dis-host-rul :
define parameter buffer buf_dis-host for ub.dis-host .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if g#db-num > 0 then return.
  if not available buf_dis-host then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-host':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-host':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'dis-host':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-host:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-host':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  if g#db-num = 0 then do:
   case buf_temp-hist-nws-option.smart-nws:
      when integer('0':U)
      or
      when integer('10':U) then do:
        if buf_dis-host.dt-code = 0
        and buf_dis-host.host-code  = 0
        and buf_Dis-host.whole-send-news = integer('-1':U) then do:
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
        else do:
          run get-db-list-for-d-card2  in this-procedure ( input buf_dis-host.d-card).
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input yes
                                                      ).
        end.
      end.
      when integer('1':U) then do:
        if buf_dis-host.dt-code = 0
        and buf_dis-host.host-code  = 0
        and buf_Dis-host.whole-send-news = integer('-1':U) then do:
          run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                      ,input buffer buf_dis-host:handle
                                                      ,input buf_dis-host.d-card
                                                      ,input v-rec-ord1
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                    ,input -1).
        end.
      end.
      otherwise do:
        run create-smart-route-link in this-procedure ( input 'dis-host':U
                                                    ,input buffer buf_dis-host:handle
                                                    ,input buf_dis-host.d-card
                                                    ,input v-rec-ord1
                                                    ,input no
                                                    ).
        run create-smart-route in this-procedure  ( input buf_dis-host.d-card
                                                  ,input -1).
      end.
    end.
  end.
end.
end procedure.
procedure get-db-list-for-d-card2 :
define input parameter p-d-card as character no-undo .
define variable v-current-db-processed as logical no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error return-value
  :
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = p-d-card,
       first buf_clients no-lock where
            buf_clients.obj-type = buf_dis-obj.obj-type
        and buf_clients.obj-code = buf_dis-obj.obj-code
    break by
    buf_clients.db-num:
      if first-of(buf_Clients.db-num) then do:
        find first buf_temp-smart-route no-lock where
              buf_temp-smart-route.key-field = p-d-card
          and buf_temp-smart-route.db-num = buf_clients.db-num
              no-error.
        if available buf_temp-smart-route then return.
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = buf_clients.db-num
        .
        if buf_clients.db-num = g#db-num then do:
          v-current-db-processed = yes.
        end.
      end.
    end.
    if not v-current-db-processed then do:
      find first buf_temp-smart-route no-lock where
            buf_temp-smart-route.key-field = p-d-card
        and buf_temp-smart-route.db-num = g#db-num  no-error.
      if not available buf_temp-smart-route then do:
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = g#db-num
        .
      end.
    end.
  end.
end procedure.
define temp-table temp-dis-card no-undo like ub.dis-card.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-dis-card  for temp-dis-card.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discardh_write-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-card':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = 2
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-card':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card.
  buffer-copy buf_dis-card to buf_c-dis-card
  assign
  buf_c-dis-card.d-card             = buf_dis-card.d-card
  buf_c-dis-card.card-num           = buf_dis-card.card-num
  buf_c-dis-card.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-card.corr-time          = v-time
  buf_c-dis-card.corr-user-db-num   = g#db-num
  buf_c-dis-card.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else g#userid
                                            )
                                        )
  buf_c-dis-card.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-card to buf_c-dc-hist
  assign
  buf_c-dc-hist.action =  p-action
  buf_c-dc-hist.subject = 'dis-card':U
  buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dis-card':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-card:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-card':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-dis-card':U
                                                    ,input buffer buf_c-dis-card:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                    ,input buffer buf_c-dc-hist:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure discardh_send-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if g#db-num > 0 then return.
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'dis-card':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-card:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  run create-smart-route-link in this-procedure ( input 'dis-card':U
                                                ,input buffer buf_dis-card:handle
                                                ,input buf_dis-card.d-card
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                              ,input -1).
end.
end procedure.
define temp-table temp-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_temp-dis-card-property  for temp-dis-card-property.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure disproph_write-dis-card-property-rul :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if not available buf_dis-card-property then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-card-property':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-card-property':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card-property.
  buffer-copy buf_dis-card-property to buf_c-dis-card-property
  assign
  buf_c-dis-card-property.d-card             = buf_dis-card-property.d-card
  buf_c-dis-card-property.host-code          = buf_dis-card-property.host-code
  buf_c-dis-card-property.obj-type           = buf_dis-card-property.obj-type
  buf_c-dis-card-property.obj-code           = buf_dis-card-property.obj-code
  buf_c-dis-card-property.card-num           = buf_dis-card-property.card-num
  buf_c-dis-card-property.dt-code            = buf_dis-card-property.dt-code
  buf_c-dis-card-property.node-code          = buf_dis-card-property.node-code
  buf_c-dis-card-property.main-card          = buf_dis-card-property.main-card
  buf_c-dis-card-property.first-main-card    = buf_dis-card-property.first-main-card
  buf_c-dis-card-property.first-card         = buf_dis-card-property.first-card
  buf_c-dis-card-property.chip-num           = next-value (s-dc-chip, ub)
  buf_c-dis-card-property.corr-time          = v-time
  buf_c-dis-card-property.corr-user-db-num   = g#db-num
  buf_c-dis-card-property.corr-user-name    = (if g#news
                                                then (chr(4) +  'СПН':U)
                                                else (if g#esys
                                                      then (chr(4) +  'ВС':U)
                                                      else g#userid
                                                      )
                                                )
  buf_c-dis-card-property.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-card-property to buf_c-dc-hist
  assign
  buf_c-dc-hist.action = p-action
  buf_c-dc-hist.subject = 'dis-card-property':U
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                              then '':U
                              else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
  and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dis-card-property':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dis-card-property:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dis-card-property':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-dc-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-dc-hist:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-dc-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
     case buf_temp-hist-nws-option.smart-nws:
        when integer('0':U)
        or
        when integer('10':U)
        then do:
          run get-db-list-for-d-card3  in this-procedure ( input buf_dis-card-property.d-card).
          run create-smart-route-link in this-procedure ( input 'c-dis-card-property':U
                                                      ,input buffer buf_c-dis-card-property:handle
                                                      ,input buf_dis-card-property.d-card
                                                      ,input v-rec-ord2
                                                      ,input yes
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-card-property.d-card
                                                      ,input v-rec-ord3
                                                      ,input yes
                                                      ).
        end.
        when integer('1':U) then do:
        end.
        otherwise do:
          run create-smart-route-link in this-procedure ( input 'c-dis-card-property':U
                                                      ,input buffer buf_c-dis-card-property:handle
                                                      ,input buf_dis-card-property.d-card
                                                      ,input v-rec-ord2
                                                      ,input no
                                                      ).
          run create-smart-route-link in this-procedure ( input 'c-dc-hist':U
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-card-property.d-card
                                                      ,input v-rec-ord3
                                                      ,input no
                                                      ).
          run create-smart-route in this-procedure  ( input buf_dis-card-property.d-card
                                                    ,input -1).
        end.
      end case.
    end.
  end.
end.
end procedure.
procedure disproph_send-dis-card-property-rul :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if g#db-num > 0 then return.
  if not available buf_dis-card-property then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'dis-card-property':U
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'dis-card-property':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'dis-card-property':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-card-property:handle                                                                                    ,input ''                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-property':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  if g#db-num = 0 then do:
    case buf_temp-hist-nws-option.smart-nws:
      when integer('0':U)
      or
      when integer ('10':U)
      then do:
          run get-db-list-for-d-card3  in this-procedure ( input buf_dis-card-property.d-card).
          run create-smart-route-link in this-procedure ( input 'dis-card-property':U
                                                      ,input buffer buf_dis-card-property:handle
                                                      ,input buf_dis-card-property.d-card
                                                      ,input v-rec-ord1
                                                      ,input yes
                                                      ).
      end.
      when integer('1':U) then do:
      end.
      otherwise do:
        run create-smart-route-link in this-procedure ( input 'dis-card-property':U
                                                    ,input buffer buf_dis-card-property:handle
                                                    ,input buf_dis-card-property.d-card
                                                    ,input v-rec-ord1
                                                    ,input no
                                                    ).
        run create-smart-route in this-procedure  ( input buf_dis-card-property.d-card
                                                  ,input -1).
      end.
    end case.
  end.
end.
end procedure.
procedure get-db-list-for-d-card3 :
define input parameter p-d-card as character no-undo .
define variable v-current-db-processed as logical no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error return-value
  :
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = p-d-card,
       first buf_clients no-lock where
            buf_clients.obj-type = buf_dis-obj.obj-type
        and buf_clients.obj-code = buf_dis-obj.obj-code
    break by
    buf_clients.db-num:
      if first-of(buf_Clients.db-num) then do:
        find first buf_temp-smart-route no-lock where
              buf_temp-smart-route.key-field = p-d-card
          and buf_temp-smart-route.db-num = buf_clients.db-num
              no-error.
        if available buf_temp-smart-route then return.
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = buf_clients.db-num
        .
        if buf_clients.db-num = g#db-num then do:
          v-current-db-processed = yes.
        end.
      end.
    end.
    if not v-current-db-processed then do:
      find first buf_temp-smart-route no-lock where
            buf_temp-smart-route.key-field = p-d-card
        and buf_temp-smart-route.db-num = g#db-num
            no-error.
      if not available buf_temp-smart-route then do:
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = g#db-num
        .
      end.
    end.
  end.
end procedure.
define temp-table temp-clients no-undo like ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_temp-clients  for temp-clients.
define temp-table temp-firm no-undo like ub.firm.
define buffer buf_firm for ub.firm.
define buffer buf_temp-firm  for temp-firm.
define temp-table temp-person no-undo like ub.person.
define buffer buf_person for ub.person.
define buffer buf_temp-person  for temp-person.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clientsh_write-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'clients':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'clients':U
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-clients.
  buffer-copy buf_clients to buf_c-clients
  assign
  buf_c-clients.obj-type           = buf_clients.obj-type
  buf_c-clients.obj-code           = buf_clients.obj-code
  buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
  buf_c-clients.corr-time          = v-time
  buf_c-clients.corr-user-db-num   = g#db-num
  buf_c-clients.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-clients.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-clients to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'clients':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = p-doc-type
  buf_c-cli-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-clients':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-clients:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-clients':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-clients':U
                                                    ,input buffer buf_c-clients:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'clients':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_clients:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'clients':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'clients':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'clients':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'clients':U
                                                ,input buffer buf_clients:handle
                                                ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                              ,input -1).
end.
end procedure.
procedure clientsh_write-firm-rul  :
define parameter buffer buf_firm for ub.firm .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'firm':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'firm':U
    buf_temp-hist-nws-option.key#_one = 2
    .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-firm.
  buffer-copy buf_firm to buf_c-firm
  assign
  buf_c-firm.firm-code          = buf_firm.firm-code
  buf_c-firm.chip-num           = next-value (s-cli-chip, ub)
  buf_c-firm.corr-time          = v-time
  buf_c-firm.corr-user-db-num   = g#db-num
  buf_c-firm.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-firm.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-firm to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'firm':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = 'trn-doc':U
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-firm':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-firm:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-firm':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-firm':U
                                                    ,input buffer buf_c-firm:handle
                                                    ,input string(buf_firm.firm-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ('орг':U + string(buf_firm.firm-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input ('орг':U + string(buf_firm.firm-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-firm-rul  :
define parameter buffer buf_firm for ub.firm.
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'firm':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_firm:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'firm':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'firm':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'firm':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'firm':U
                                                ,input buffer buf_firm:handle
                                                ,input ('орг':U + string(buf_firm.firm-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input ('орг':U + string(buf_firm.firm-code))
                                              ,input -1).
end.
end procedure.
procedure clientsh_write-person-rul  :
define parameter buffer buf_person for ub.person .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'person':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'person':U
    buf_temp-hist-nws-option.key#_one = 2
    .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.
  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-person.
  buffer-copy buf_person to buf_c-person
  assign
  buf_c-person.psn-code           = buf_person.psn-code
  buf_c-person.chip-num           = next-value (s-cli-chip, ub)
  buf_c-person.corr-time          = v-time
  buf_c-person.corr-user-db-num   = g#db-num
  buf_c-person.corr-user-name     = (if g#news
                                      then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                           then (chr(4) +  'ВС':U)
                                           else g#userid)
                                     )
  buf_c-person.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-person to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = 'person':U
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = 'trn-doc':U
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-person':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-person:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord2                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-person':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'c-cli-hist':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_c-cli-hist:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord3                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'c-cli-hist':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input 'c-person':U
                                                    ,input buffer buf_c-person:handle
                                                    ,input string(buf_person.psn-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).
      run create-smart-route-link in this-procedure ( input 'c-cli-hist':U
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ('орг':U + string(buf_person.psn-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).
      run create-smart-route in this-procedure  ( input ('орг':U + string(buf_person.psn-code))
                                                ,input -1).
    end.
  end.
end.
end procedure.
procedure clientsh_send-person-rul  :
define parameter buffer buf_person for ub.person.
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.
do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  run add-dump in v-cmd-proc-handle                                                                           (input buf_temp-cmd.cmd-code                                                                                         ,input 'person':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_person:handle                                                                                    ,input '':U                                                                                         ,output v-rec-ord1                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'person':U                                                                                                ,buf_temp-cmd.cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = 'person':U
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = 'person':U
    buf_temp-hist-nws-option.smart-nws = integer('-1':U)
    .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option-record in g#lib-nws
  (input  g#db-num
  ,input  buffer buf_temp-hist-nws-option:handle
  )  .
  end.
  run create-smart-route-link in this-procedure ( input 'person':U
                                                ,input buffer buf_person:handle
                                                ,input ('орг':U + string(buf_person.psn-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).
  run create-smart-route in this-procedure  ( input ('орг':U + string(buf_person.psn-code))
                                              ,input -1).
end.
end procedure.
define temp-table temp-prop-ref no-undo like ub.prop-ref.
define buffer buf_temp-xml-tables for temp-xml-tables.
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .
define variable v-step     as integer   no-undo .
define variable v-proc-name as character no-undo .
define variable v-db-list     as character no-undo .
define variable v-command     as character no-undo .
define variable v-cmd-code    as integer no-undo .
define variable log-file-name as character no-undo .
define variable v-num-dc      as integer no-undo .
define variable v-doc-code as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-ruleset_id as integer no-undo .
define variable v-ruleset_id-list as character no-undo .
define variable v-codex_id as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-call-id as character no-undo .
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-h-action as integer no-undo .
define variable v-doc-type as character no-undo .
define variable v-temp-d-card-mode as logical no-undo .
define variable type# as character no-undo .
define variable emitent-host-code# as integer no-undo .
define variable dtm-code# as integer no-undo .
define variable v-save-int as integer no-undo .
define variable v-nws-to-cd as integer   no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-curr-rowid as rowid no-undo .
define variable sign as integer no-undo .
define variable v-stop-leave-status as character no-undo .
define variable v-is-empty as logical no-undo .
define buffer buf_db for ub.db.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_temp-pers-proc  for temp-pers-proc.
define buffer buf_Inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_Doc-line for ub.doc-line.
define buffer bf_trn-doc for ub.trn-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf1_temp-cmd  for temp-cmd.
define buffer buf_temp-smart-route  for temp-smart-route.
define buffer buf_temp-smart-link  for temp-smart-link.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-no-route  for temp-no-route.
define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-step > 3
  or p-step = 3 and g#db-num > 0 then return.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
  IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.
  file-info:filename = "cmdp-dc.log".
  if file-info:full-pathname <> ? then do:
    assign
    log-file-name = "cmdp-dc.log".
  end.
  if (p-step = 2
     and
     g#db-num = 0)
  or p-step = 3 then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Прием в БД &1 подтверждения получения данных по ДК в БД &2: &3 &4&5"
                          , g#db-num
                          , g#news-source-db
                          , p-cmd-doc-code
                          , p-obj-type
                          , (if p-obj-code > 0 then string(p-obj-code) else '':U))) no-error .
  end.
  else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Получение данных по ДК из БД &1: &2 &3 &4&5"
                          , g#news-source-db
                          , entry (lookup (p-cmd-doc-type, 'sale-close,sale-delete,trn-doc-close,trn-doc-delete,sale-xml-import,text-import,text-export,one-card-recalc,one-card-check,one-card-add,batch-card-recalc,stop-list-import,payment-on-card,fin-doc-on-card,delete-fin-doc-from-card':U) + 1, ',' + 'Закрытие продажи на факт,Удаление закрытой продажи,Закрытие накл. с ДК на факт,Удаление накл. с ДК,Импорт продаж в XML виде,Импорт данных в текст.виде,Экспорт данных в текст.виде,Пересчет по одной карте,Проверка одной карты,Добавление одной карты,Пересчет карт,Импорт стоплиста,Внесение средств на карту,Внес.пл-жа на карту через сист.взаиморасчетов,Удал.пл-жа с карты через сист.взаиморасчетов':U)
                          , p-cmd-doc-code
                          , p-obj-type
                          , (if p-obj-code > 0 then string(p-obj-code) else '':U))) no-error .
  end.
  for each temp-d-card:
    delete temp-d-card.
  end.
  for each temp-hist-nws-option:
    delete temp-hist-nws-option.
  end.
  for each temp-dis-obj:
    delete temp-dis-obj.
  end.
  for each temp-dis-host:
    delete temp-dis-host.
  end.
  for each temp-dis-card:
    delete temp-dis-card.
  end.
  for each temp-dis-card-property:
    delete temp-dis-card-property.
  end.
  for each temp-prop-ref:
    delete temp-prop-ref.
  end.
  for each temp-clients:
    delete temp-clients.
  end.
  for each temp-firm:
    delete temp-firm.
  end.
  for each temp-person:
    delete temp-person.
  end.
  assign
  v-current-obj-type = p-obj-type
  v-current-obj-code = p-obj-code
  .
  if not (p-cmd-doc-type = 'batch-card-recalc':U
          or
          p-cmd-doc-type = 'one-card-check':U
          or
          p-cmd-doc-type = 'one-card-add':U
          or
          p-cmd-doc-type = 'sale-xml-import':U
          or
          p-cmd-doc-type = 'payment-on-card':U
          or
          p-cmd-doc-type = 'fin-doc-on-card':U
          or
          p-cmd-doc-type = 'delete-fin-doc-from-card':U
          or
          p-cmd-doc-type = ('stop-list-import':U + chr(4) + 'ДОБАВЛЕНИЕ':U)
          or
          p-cmd-doc-type = ('stop-list-import':U + chr(4) + 'ИЗМЕНЕНИЕ':U)
          ) then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-current-obj-type
  ,input  v-current-obj-code
  ,output v-host-code
  )  .
  end.
  if p-cmd-doc-type <> 'batch-card-recalc':U then do:
    if g#db-num = 0
    and p-step = 1 then do:
      define variable v-lock-dc-type as character no-undo .
      case p-cmd-doc-type:
        when 'sale-close':U
        or
        when 'sale-delete':U
        then do:
           v-lock-dc-type = 'inkas':U.
        end.
        when 'trn-doc-close':U
        or
        when 'trn-doc-delete':U
        then do:
           v-lock-dc-type = 'trn-doc':U.
        end.
        when 'one-card-recalc':U
        or
        when 'one-card-add':U
        then do:
          v-lock-dc-type = 'dis-card':U.
        end.
      end case.
      run str/lock-dc.p (
                    input p-log-handle
                    ,input this-procedure:handle
                    ,input v-lock-dc-type
                    ,input p-cmd-doc-code
                    ,input '':U
                    ,input p-step
                    ,input g#news
                    ,input log-file-name
                    ,output v-num-dc
                    ) no-error.
      if error-status:error then do:
        undo _main, return error substitute("&1 &2 &3&4Ошибка при блокировании ДК по документу &7&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ,p-cmd-doc-code
                                          ).
      end.
    end.
  end.
  define variable v-base-code as integer   no-undo .
  if v-host-code > 0 then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
  end.
  define variable v-curr-r-b as character no-undo .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  v-cntxt-db-num = g#db-num.
  case p-cmd-doc-type:
    when 'sale-close':U
    or
    when 'sale-delete':U
    then do:
      if g#db-num = 0
      and p-step = 1 then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable cre-pay-base       like ub.dis-obj.pay-tot-base no-undo.
define variable cre-pay-rubl       like ub.dis-obj.pay-tot-rubl no-undo.
define variable chk-exch           as decimal no-undo.
define variable chk-exch-rubl      as decimal no-undo.
define variable chk-exch-base      as decimal no-undo.
define variable v-rate             as decimal no-undo .
define variable accum-tot-rubl     like ub.chk-pay.tot-rubl  no-undo .
define variable accum-tot-base     like ub.chk-pay.tot-rubl  no-undo .
define variable accum-cre-pay-base like ub.chk-pay.tot-rubl  no-undo .
define variable accum-cre-pay-rubl like ub.chk-pay.tot-rubl  no-undo .
define variable ret-doc-code as character no-undo .
        find first buf_inkas exclusive-lock
          where buf_inkas.inkas-code = p-cmd-doc-code
          no-error .
        if not available buf_inkas then do:
          undo, return error
          substitute("&1 &2 &3 Ошибка задания входных параметров: не найдена продажа &4"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,p-cmd-doc-code)
          .
        end.
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = p-cmd-doc-code no-error .
        if not available buf_trn-doc then do:
          undo , return error substitute("Не найден документ с номером &1", p-cmd-doc-code).
        end.
        find first buf_ret-doc no-lock where
                  buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
        if available buf_ret-doc then do:
          ret-doc-code = buf_ret-doc.doc-code.
        end.
        else do:
          ret-doc-code = '':U.
        end.
      end.
      assign
      sign = p-sign
      v-doc-type = 'trn-doc':U
      p-doc-type = 'trn-doc':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      .
      assign
      v-ruleset_id =  (if p-sign = 1
                      then 1
                      else 2)
      v-codex_id = 2
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(v-ruleset_id) + chr(44) + string(9))
                          else '':U)
      .
    end.
    when 'trn-doc-close':U
    or
    when 'trn-doc-delete':U
    then do:
      if g#db-num = 0
      and p-step = 1 then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v-other-base        like ub.ot-line.other-base      no-undo .
define variable v-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
DEFINE VARIABLE accumdl-sum-rubl as decimal no-undo .
DEFINE VARIABLE accumdl-sum-base as decimal no-undo .
        find first bf_trn-doc no-lock where
                  bf_trn-doc.doc-code = p-cmd-doc-code no-error .
        if not available bf_trn-doc then do:
          undo , return error substitute("Не найден документ с номером &1", p-cmd-doc-code).
        end.
        FIND FIRST buf_dis-card WHERE
                  buf_dis-card.d-card = bf_trn-doc.d-card NO-LOCK .
      end.
      assign
      v-doc-type = 'trn-doc':U
      p-doc-type = 'trn-doc':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      sign  = p-sign
      .
      assign
      v-ruleset_id = (if p-sign = 1
                      then 3
                      else 4)
      v-codex_id = 2
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(v-ruleset_id)  + chr(44) + string(9))
                          else '':U)
      .
    end.
    when 'batch-card-recalc':U
    or
    when 'one-card-check':U
    then do:
      assign
      v-doc-type = 'recalc':U
      p-doc-type = 'recalc':U
      v-doc-code = '':U
      v-process-file-name = '':U
      p-doc-code = '':U
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when 'text-import':U
    then do:
      assign
      v-doc-type = 'import':U
      p-doc-type = 'import':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when 'sale-xml-import':U
    then do:
      assign
      v-doc-type = 'import':U
      p-doc-type = 'import':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-codex_id = (if g#db-num = 0 and p-step = 1
                    then 2
                    else 0)
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(6)  + chr(44) + string(5) + chr(44) + string(9))
                          else '':U)
      sign = p-sign
      .
    end.
    when 'one-card-add':U then do:
      assign
      v-doc-type = '':U
      p-doc-type = '':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when 'payment-on-card':U then do:
      assign
      v-doc-type = 'payment':U
      p-doc-type = 'payment':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when 'fin-doc-on-card':U
    or
    when 'delete-fin-doc-from-card':U
    then do:
      assign
      v-doc-type = 'payment':U
      p-doc-type = 'payment':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when ('stop-list-import':U + chr(4) +  'ДОБАВЛЕНИЕ':U)
    or
    when ('stop-list-import':U + chr(4) +  'ИЗМЕНЕНИЕ':U)
    then do:
      assign
      v-doc-type = 'stop-list':U
      p-doc-type = 'stop-list':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры cmdp-dc.p&4Невернoе значение p-cmd-doc-type = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,p-cmd-doc-type
                                          ).
    end.
  end case.
  if p-step < 2
  or g#db-num > 0
  then do:
    v-step = p-step + 1.
    if not valid-handle(v-cmd-proc-handle ) then dO:
      run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
      if error-status :error
      then do:
        delete procedure v-cmd-proc-handle .
        undo _main, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                            "&5&4&6"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
    end.
    for each buf_temp-cmd:
      delete buf_temp-cmd.
    end.
    for each buf_temp-smart-route:
      delete buf_temp-smart-route.
    end.
    for each buf_temp-smart-link:
      delete buf_temp-smart-link.
    end.
    for each buf_temp-no-route:
      delete buf_temp-no-route.
    end.
    if g#db-num = 0 then do:
      create buf_temp-cmd.
      assign
      buf_temp-cmd.db-list = string( -1)
      .
      for each buf_db no-lock:
        if buf_db.db-num = 0 then next.
        create buf_temp-cmd.
        assign
        buf_temp-cmd.db-list = string(buf_db.db-num)
        .
      end.
    end.
    else do:
      create buf_temp-cmd.
      assign
      buf_temp-cmd.db-list = string(0)
      .
    end.
    define variable v-ii as integer no-undo .
    v-command = 'cmd-process-saledc':U + chr(6) +
                string(v-step) + chr(6) +
                string(p-source-db-num)             + chr(6) +
                p-obj-type + chr(6) +
                string(p-obj-code) + chr(6) +
                p-cmd-doc-code + chr(6) +
                p-cmd-doc-type + chr(6) +
                p-ext-doc-type + chr(6) +
                (if p-doc-date = ? then chr(63) else string(p-doc-date)) + chr(6) +
                (if p-fact-date = ? then chr(63) else string(p-fact-date)) + chr(6) +
                string(p-sign) + chr(6) +
                string(cre-pay).
    for each buf_temp-cmd:
      run begin-create-command in v-cmd-proc-handle
        (input  v-command
        ,INPUT  buf_temp-cmd.db-list
        ,output buf_temp-cmd.cmd-code
        ) no-error.
      if error-status :error
      then do:
        delete procedure v-cmd-proc-handle .
        undo _main, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,'cmd-process-saledc':U
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
    end.
    find first buf_temp-cmd use-index pi.
  end.
  do counter = 1 to p-counter
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, chr(1) )
    .
    CASE entry(1, v-rec-name, chr(4)) :
      when 'nws-outline':U then do:
        create buf_temp-nws-outline .
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-nws-outline:handle)
          ) no-error.
        if error-status :error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        if g#db-num = 0 and p-step = 1 then do:
          if buf_temp-nws-outline.outline-type = 'dis-card':U
          then do:
            if p-cmd-doc-type = 'batch-card-recalc':U
            and p-step = 1
            then do:
              run str/lock-dc.p (
                            input p-log-handle
                            ,input this-procedure:handle
                            ,input p-cmd-doc-type
                            ,input p-cmd-doc-code
                            ,input buf_temp-nws-outline.charkey_one
                            ,input p-step
                            ,input g#news
                            ,input log-file-name
                            ,output v-num-dc
                            ) no-error.
              if error-status:error then do:
                delete procedure v-cmd-proc-handle .
                undo _main, return error substitute("&1 &2 &3&4Ошибка при блокировании ДК по документу &7&4" +
                                                  "&5&4&6&4&7"
                                                  ,vss-workfile
                                                  ,vss-revision
                                                  ,vss-description
                                                  ,chr(10)
                                                  ,error-status:get-message(1)
                                                  ,return-value
                                                  ,p-cmd-doc-code
                                                  ,buf_temp-nws-outline.charkey_one
                                                  ).
              end.
            end.
          end.
          if buf_temp-nws-outline.no-id > 1
          and buf_temp-nws-outline.outline-type = 'dis-card-type':U
          then do:
            v-call-id = buf_temp-nws-outline.charkey_one.
            run gen-row-keyr in this-procedure (
                                                 input v-call-id
                                                ,input ?
                                                ,input "ub"
                                                ,input ?
                                                ,input no-lock
                                                ,output v-tbl-row
                                                ,output v-tbl-name).
           find first buf_dis-card-type no-lock where
                    rowid(buf_dis-card-type) = v-tbl-row.
            do  v-ii = 1 to num-entries(v-ruleset_id-list):
              v-ruleset_id = integer(entry(v-ii, v-ruleset_id-list)).
              _rule-by-call:
              for each buf_rule-by-call no-lock where
                        buf_rule-by-call.call_id = v-call-id
                  and buf_rule-by-call.can-calc = yes
                  and buf_rule-by-call.codex_id = v-codex_id
                  and buf_rule-by-call.ruleset_id = v-ruleset_id
              by buf_rule-by-call.call_id
              by buf_rule-by-call.codex_id
              by buf_rule-by-call.ruleset_id
              by buf_rule-by-call.order_id
              on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
              on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
              on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
                v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
                if no then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first buf_temp-pers-proc where
          buf_temp-pers-proc.proc-name = v-proc-name no-error.
if not available buf_temp-pers-proc then do:
  v-proc-handle = ?.
  run value(v-proc-name) persistent set v-proc-handle (
                                                        input parparentproc
                                                      ,input this-procedure:handle
                                                      ,input p-log-handle
                                                      ,input ?
                                                      ,input v-codex_id
                                                      ,input v-ruleset_id
                                                      ,input buf_rule-by-call.call_id
                                                      ,input buf_rule-by-call.order_id
                                                      ,input buf_rule-by-call.rule_id
                                                      ,input buf_rule-by-call.profile
                                                      ,input buf_rule-by-call.is_dynamic
                                                      ,input v-doc-type
                                                      ,input v-host-code
                                                      ,input p-obj-type
                                                      ,input p-obj-code
                                                      ,input v-doc-code
                                                      ,input p-doc-date
                                                      ,input p-fact-date
                                                      ,input 0
                                                      ,input v-curr-r-b
                                                      ,input v-cmd-proc-handle
                                                      ,input buf_temp-cmd.cmd-code
                                                      ,input table temp-d-card
                                                      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  run perproc-create-proc in this-procedure (
                                              input  this-procedure:handle
                                              ,input  v-proc-name
                                              ,input  v-proc-handle
                                              ,input  no
                                              ,input  '':U
                                              ,input  g#userid
                                              ,input (if buf_rule-by-call.is_dynamic
                                                      then 999999999
                                                      else 0)
                                              ,output v-id ) no-error.
  if error-status:error then do:
    if return-value = '>':U
    then do:
      run perproc-delete-by-rank in this-procedure .
      run perproc-create-proc in this-procedure (
                                                  input  this-procedure:handle
                                                  ,input  ("rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p')
                                                  ,input  v-proc-handle
                                                  ,input  no
                                                  ,input  '':U
                                                  ,input  g#userid
                                                  ,input (if buf_rule-by-call.is_dynamic
                                                          then 999999999
                                                          else 0)
                                                  ,output v-id ) .
    end.
    else do:
      delete procedure v-cmd-proc-handle .
      undo _main, return error substitute("&1&2Ошибка при вызове обработки ДК типа &3 эмитент &4"
                                          ,vss-workfile
                                          ,chr(10)
                                          ,v-type
                                          ,v-emitent-host-code).
    end.
  end.
  find first buf_temp-pers-proc where
            buf_temp-pers-proc.id = v-id .
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end.
else do:
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end.
run proc-main in buf_temp-pers-proc.vproc-handle (
                                                  input v-type
                                                  ,input v-emitent-host-code
                                                  ) no-error .
if error-status:error then do:
  delete procedure v-cmd-proc-handle .
  undo _main, return error substitute("&1&2Ошибка при вызове обработке ДК типа &3 эмитент &4"
                                        ,vss-workfile
                                        ,chr(10)
                                        ,v-type
                                        ,v-emitent-host-code).
end.
                end.
                else do:
                  run value(v-proc-name) (
                                                                       input parparentproc
                                                                      ,input this-procedure:handle
                                                                      ,input p-log-handle
                                                                      ,input ?
                                                                      ,input v-codex_id
                                                                      ,input v-ruleset_id
                                                                      ,input buf_rule-by-call.call_id
                                                                      ,input buf_rule-by-call.order_id
                                                                      ,input buf_rule-by-call.rule_id
                                                                      ,input buf_rule-by-call.profile
                                                                      ,input buf_rule-by-call.is_dynamic
                                                                      ,input v-doc-type
                                                                      ,input v-host-code
                                                                      ,input p-obj-type
                                                                      ,input p-obj-code
                                                                      ,input v-doc-code
                                                                      ,input v-process-file-name
                                                                      ,input p-doc-date
                                                                      ,input p-fact-date
                                                                      ,input 0
                                                                      ,input v-curr-r-b
                                                                      ,input v-cmd-proc-handle
                                                                      ,input buf_temp-cmd.cmd-code
                                                                      ,input buf_dis-card-type.type
                                                                      ,input buf_dis-card-type.emitent-host-code
                                                                      ,input table temp-d-card
                                                                      ) no-error .
                  if error-status:error then do:
                    delete procedure v-cmd-proc-handle .
                    undo _main, return error substitute("&1&2Ошибка при вызове обработке ДК типа &3 эмитент &4&2&5&2&6"
                                                          ,vss-workfile
                                                          ,chr(10)
                                                          ,buf_dis-card-type.type
                                                          ,buf_dis-card-type.emitent-host-code
                                                          ,error-status:get-message(1)
                                                          ,return-value
                                                          ).
                  end.
                  if v-stop-leave-status > '' then do:
                    delete procedure v-cmd-proc-handle .
                    undo _main, return error substitute("&1&2Процесс обработке ДК типа &3 эмитент &4 ПРЕРВАН&2" +
                                                        "&5&2&6"
                                                        ,vss-workfile
                                                        ,chr(10)
                                                        ,buf_dis-card-type.type
                                                        ,buf_dis-card-type.emitent-host-code
                                                        ,error-status:get-message(1)
                                                        ,return-value
                                                          ).
                  end.
                end.
              end.
            end.
            assign
            v-call-id = buf_temp-nws-outline.charkey_one
            .
          end.
        end.
      end.
      when 'hist-nws-option':U then do:
        run proc-load-standart in p-imp-handle
          ( input 'hist-nws-option':U
            ,input '':U
            ,input (buffer buf_temp-hist-nws-option:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      when 'dis-obj':U then do:
        v-h-action = integer('2':U).
        create buf_temp-dis-obj.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-obj:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
                        run proc-verify-d-card in this-procedure (                                                       input entry(1, v-rec-name, chr(4))                                                      ,input buf_temp-dis-obj.d-card                                                      ,input  buf_temp-dis-obj.dt-code                                                      ,output type#                                                          ,output emitent-host-code#                                                       ,output dtm-code#) no-error .           if error-status:error then do:             delete procedure v-cmd-proc-handle .             undo _main, return error return-value .            end.
        find first buf_dis-obj exclusive-lock where
                buf_dis-obj.d-card = buf_temp-dis-obj.d-card
            and buf_dis-obj.obj-type = buf_temp-dis-obj.obj-type
            and buf_dis-obj.obj-code = buf_temp-dis-obj.obj-code
            and buf_dis-obj.dt-code = buf_temp-dis-obj.dt-code
            no-error.
        if not available buf_dis-obj then do:
          create buf_dis-obj.
          buffer-copy buf_temp-dis-obj
          using d-card host-code obj-type obj-code dt-code main-card first-card first-main-card card-num
          to buf_dis-obj.
          v-h-action = integer('1':U).
        end.
        run dis-objh_write-dis-obj-rul  in this-procedure (
                                                  buffer buf_dis-obj
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-Dis-obj to buf_dis-obj.
        if g#db-num = 0
        and p-step = 1 then do:
          run dis-objh_send-dis-obj-rul  in this-procedure (
                                                  buffer buf_dis-obj
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num = 0 then do:
          v-nws-to-cd = integer('0':U).
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-obj':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  type#
  ,input  '':U
  ,input  '':U
  ,input  emitent-host-code#
  ,input  dtm-code#
  ,input  0
  ,input  'nws-to-cd'
  ,output v-nws-to-cd
  ) no-error .
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-obj.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-obj to dc-list.
          end.
        end.
        delete buf_temp-dis-obj.
      end.
      when 'temp-d-card' then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = 'temp-d-card'  .
        buf_temp-xml-tables.tbl-handle_:buffer-create().
        run nws-impl-without-check in p-imp-handle
          ( input buf_temp-xml-tables.tbl-handle_
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_temp-d-card where
                buf_temp-d-card.d-card = buf_temp-xml-tables.tbl-handle_:buffer-field("d-card"):buffer-value
            and buf_temp-d-card.obj-type = buf_temp-xml-tables.tbl-handle_:buffer-field("obj-type"):buffer-value
            and buf_temp-d-card.obj-code = buf_temp-xml-tables.tbl-handle_:buffer-field("obj-code"):buffer-value
            no-error.
        if not available buf_temp-d-card then do:
          create buf_temp-d-card.
          buffer buf_temp-d-card:handle:buffer-copy (buf_temp-xml-tables.tbl-handle_).
        end.
        buf_temp-xml-tables.tbl-handle_:buffer-delete().
      end.
      when 'vchk-pay' then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = 'vchk-pay'  .
        buf_temp-xml-tables.tbl-handle_:buffer-create().
        run nws-impl-without-check in p-imp-handle
          ( input buf_temp-xml-tables.tbl-handle_
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first vchk-pay where
                vchk-pay.d-card = buf_temp-xml-tables.tbl-handle_:buffer-field("d-card"):buffer-value
            and vchk-pay.pay-code = buf_temp-xml-tables.tbl-handle_:buffer-field("pay-code"):buffer-value
            and vchk-pay.curr-code = buf_temp-xml-tables.tbl-handle_:buffer-field("curr-code"):buffer-value
            and vchk-pay.doc-date = buf_temp-xml-tables.tbl-handle_:buffer-field("doc-date"):buffer-value
            and vchk-pay.cre-pay = buf_temp-xml-tables.tbl-handle_:buffer-field("cre-pay"):buffer-value
            and vchk-pay.exch-rate = buf_temp-xml-tables.tbl-handle_:buffer-field("exch-rate"):buffer-value
            and vchk-pay.base-rate = buf_temp-xml-tables.tbl-handle_:buffer-field("base-rate"):buffer-value
            no-error.
        if not available vchk-pay then do:
          create vchk-pay.
          buffer vchk-pay:handle:buffer-copy (buf_temp-xml-tables.tbl-handle_).
        end.
        buf_temp-xml-tables.tbl-handle_:buffer-delete().
      end.
      when 'dis-host':U then do:
        v-h-action = integer('2':U).
        create buf_temp-dis-host.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-host:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
                        run proc-verify-d-card in this-procedure (                                                       input entry(1, v-rec-name, chr(4))                                                      ,input buf_temp-dis-host.d-card                                                      ,input  buf_temp-dis-host.dt-code                                                      ,output type#                                                          ,output emitent-host-code#                                                       ,output dtm-code#) no-error .           if error-status:error then do:             delete procedure v-cmd-proc-handle .             undo _main, return error return-value .            end.
        find first buf_dis-host exclusive-lock where
                buf_dis-host.d-card = buf_temp-dis-host.d-card
            and buf_dis-host.host-code = buf_temp-dis-host.host-code
            and buf_dis-host.dt-code = buf_temp-dis-host.dt-code
            no-error.
        if not available buf_dis-host then do:
          create buf_dis-host.
          buffer-copy buf_temp-dis-host
          using d-card host-code dt-code main-card first-card first-main-card card-num
          to buf_dis-host.
          v-h-action = integer('1':U).
        end.
        run dis-hsth_write-dis-host-rul  in this-procedure (
                                                  buffer buf_dis-host
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-host to buf_dis-host.
        if g#db-num = 0
        and p-step = 1 then do:
          run dis-hsth_send-dis-host-rul  in this-procedure (
                                                    buffer buf_dis-host
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num > 0 then do:
          v-nws-to-cd = integer('0':U).
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-host':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  type#
  ,input  '':U
  ,input  '':U
  ,input  emitent-host-code#
  ,input  dtm-code#
  ,input  0
  ,input  'nws-to-cd'
  ,output v-nws-to-cd
  ) no-error .
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-host.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-host to dc-list.
          end.
        end.
        delete buf_temp-dis-host.
      end.
      when 'dis-card':U then do:
        v-h-action = integer('2':U).
        create buf_temp-dis-card.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-card:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        if p-cmd-doc-type <> 'text-import':U then do:
                              run proc-verify-d-card in this-procedure (                                                       input entry(1, v-rec-name, chr(4))                                                      ,input buf_temp-dis-card.d-card                                                      ,input  -1                                                      ,output type#                                                          ,output emitent-host-code#                                                       ,output dtm-code#) no-error .           if error-status:error then do:             delete procedure v-cmd-proc-handle .             undo _main, return error return-value .            end.
        end.
        find first buf_dis-card exclusive-lock where
                buf_dis-card.d-card = buf_temp-dis-card.d-card no-error.
        if not available buf_dis-card then do:
          find first buf_dis-card no-lock where
                  buf_dis-card.d-card = buf_temp-dis-card.d-card no-error.
          create buf_dis-card.
          buffer-copy buf_temp-dis-card
          using d-card card-num card-num
          to buf_dis-card
          .
          v-h-action = integer('1':U).
        end.
        run discardh_write-dis-card-rul in this-procedure (
                                                  buffer buf_dis-card
                                                ,input buf_temp-dis-card.type
                                                ,input buf_temp-dis-card.emitent-host-code
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-card to buf_dis-card
        ASSIGN
        buf_dis-card.trg-param = 'no-hist':U + chr(44) + 'no-callnews':U
        .
        if g#db-num = 0
        and p-step = 1
        then do:
          run discardh_send-dis-card-rul in this-procedure (
                                                    buffer buf_dis-host
                                                  ,input buf_temp-dis-card.type
                                                  ,input buf_temp-dis-card.emitent-host-code
                                                  ,input v-h-action).
        end.
        find first  dc-list where
                   dc-list.d-card = buf_temp-dis-card.d-card no-error .
        if not available dc-list then do:
          create dc-list.
        end.
        buffer-copy buf_temp-dis-card to dc-list.
        delete buf_temp-dis-card.
      end.
      when 'dis-card-property':U then do:
        v-h-action = integer('2':U).
        create buf_temp-dis-card-property.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-card-property:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
                        run proc-verify-d-card in this-procedure (                                                       input entry(1, v-rec-name, chr(4))                                                      ,input buf_temp-dis-card-property.d-card                                                      ,input  buf_temp-dis-card-property.dt-code                                                      ,output type#                                                          ,output emitent-host-code#                                                       ,output dtm-code#) no-error .           if error-status:error then do:             delete procedure v-cmd-proc-handle .             undo _main, return error return-value .            end.
        find first buf_dis-card-property exclusive-lock where
                buf_dis-card-property.d-card = buf_temp-dis-card-property.d-card
            and buf_dis-card-property.dt-code = buf_temp-dis-card-property.dt-code
            and buf_dis-card-property.node-code = buf_temp-dis-card-property.node-code
            and buf_dis-card-property.host-code = buf_temp-dis-card-property.host-code
            and buf_dis-card-property.obj-type = buf_temp-dis-card-property.obj-type
            and buf_dis-card-property.obj-code = buf_temp-dis-card-property.obj-code   no-error.
        if not available buf_dis-card-property then do:
          create buf_dis-card-property.
          v-h-action = integer('1':U).
          buffer-copy buf_temp-dis-card-property
          using d-card host-code obj-type obj-code dt-code node-code main-card first-card first-main-card card-num
          to buf_dis-card-property.
        end.
        run disproph_write-dis-card-property-rul  in this-procedure (
                                                  buffer buf_dis-card-property
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-card-property to buf_dis-card-property.
        if g#db-num = 0
        and p-step = 1
        then do:
          run disproph_send-dis-card-property-rul  in this-procedure (
                                                    buffer buf_dis-card-property
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num > 0 then do:
          v-nws-to-cd = integer('0':U).
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  type#
  ,input  '':U
  ,input  '':U
  ,input  emitent-host-code#
  ,input  dtm-code#
  ,input  0
  ,input  'nws-to-cd'
  ,output v-nws-to-cd
  ) no-error .
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-card-property.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-card-property to dc-list.
          end.
        end.
        delete buf_temp-dis-card-property.
      end.
      when 'clients':U then do:
        v-h-action = integer('2':U).
        create buf_temp-clients.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-clients:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_clients exclusive-lock where
                buf_clients.obj-type = buf_temp-clients.obj-type
            and buf_clients.obj-code = buf_temp-clients.obj-code no-error.
        if not available buf_clients then do:
          create buf_clients.
          buffer-copy buf_temp-clients
          using obj-type obj-code
          to buf_clients.
          v-h-action = integer('1':U).
        end.
        run clientsh_write-clients-rul  in this-procedure (
                                                  buffer buf_clients
                                                ,input v-h-action).
        buffer-copy buf_temp-clients to buf_clients.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-clients-rul  in this-procedure (
                                                    buffer buf_clients
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = buf_clients.obj-type
            AND buf_dis-card.cli-code = buf_clients.obj-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end.
        delete buf_temp-clients.
      end.
      when 'firm':U then do:
        v-h-action = integer('2':U).
        create buf_temp-firm.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-firm:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_firm exclusive-lock where
                buf_firm.firm-code = buf_temp-firm.firm-code no-error.
        if not available buf_firm then do:
          create buf_firm.
          buffer-copy buf_temp-firm
          using firm-code
          to buf_firm.
          v-h-action = integer('1':U).
        end.
        run clientsh_write-firm-rul  in this-procedure (
                                                  buffer buf_firm
                                                ,input v-h-action).
        buffer-copy buf_temp-firm to buf_firm.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-firm-rul  in this-procedure (
                                                    buffer buf_firm
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = 'орг':U
            AND buf_dis-card.cli-code = buf_firm.firm-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end.
        delete buf_temp-firm.
      end.
      when 'person':U then do:
        v-h-action = integer('2':U).
        create buf_temp-person.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-person:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_person exclusive-lock where
                buf_person.psn-code = buf_temp-person.psn-code no-error.
        if not available buf_person then do:
          create buf_person.
          buffer-copy buf_temp-person
          using psn-code
          to buf_person.
          v-h-action = integer('1':U).
        end.
        run clientsh_write-person-rul  in this-procedure (
                                                  buffer buf_person
                                                ,input v-h-action).
        buffer-copy buf_temp-person to buf_person.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-person-rul  in this-procedure (
                                                    buffer buf_person
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = 'чел':U
            AND buf_dis-card.cli-code = buf_person.psn-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end.
        delete buf_temp-person.
      end.
      when 'c-dis-obj':U
      or
      when 'c-dis-host':U
      or
      when 'c-dc-hist':U
      or
      when 'c-dis-card-property':U
      or
      when 'c-clients':U
      or
      when 'c-cli-hist':U
      or
      when 'c-firm':U
      or
      when 'c-person':U
      or
      when 'c-dis-card':U
      then do:
        run proc-load-standart in p-imp-handle
            (  input v-rec-name
              ,input '':U
              ,input ?
              ,input p-imp-handle
              ,input 0
              ,output v-curr-rowid
              ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
      end.
      otherwise do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("НЕ ПРЕДУСМОТРЕН ПРИЕМ ТАБЛИЦЫ &1 В ПРОЦЕДУРЕ", v-rec-name)
        view-as alert-box error .
        delete procedure v-cmd-proc-handle .
        undo _main, return error return-value .
      end.
    end case.
  end.
  run hide-counter in p-log-handle no-error .
  if no then do:
    run perproc-delete-from-parent  in this-procedure (
                                                        input this-procedure:handle
                                                        ,input '':U  ).
  end.
  if g#db-num = 0
  and  p-step < 2
  then do:
    find first buf1_temp-cmd where buf1_temp-cmd.db-list = string(-1).
  end.
  _temp-cmd:
  for each buf_temp-cmd
  on error undo _main, return error :
    if buf_temp-cmd.db-list = string(-1) then next _temp-cmd.
    if g#db-num = 0 then do:
      for each buf_temp-smart-link ,
      first buf_temp-smart-route
      where buf_temp-smart-route.key-field = buf_temp-smart-link.key-field
        and (buf_temp-smart-link.is-smart = no
              or buf_temp-smart-route.db-num = integer(buf_temp-cmd.db-list))
      by buf_temp-smart-link.rec-ord:
        find first buf_temp-no-route where
                  buf_temp-no-route.db-num = integer(buf_temp-cmd.db-list)
              and buf_temp-no-route.rec-ord = buf_temp-smart-link.rec-ord no-error .
        if not available buf_temp-no-route then do:
                                                            run copy-dump in v-cmd-proc-handle                                                                           (input buf1_temp-cmd.cmd-code                                                                                         ,input buf_temp-cmd.cmd-code                                                                                          ,input buf_temp-smart-link.rec-ord                                                                                    ,input buf_temp-smart-link.uniq-key-rec                                                                                    ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при копировании записи &5 из команды с кодом &6 в команду с кодом &7&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,buf_temp-smart-link.uniq-key-rec                                                                                           ,buf1_temp-cmd.cmd-code                                                                                           ,buf_temp-cmd.cmd-code                                                                                           ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
        else do:
          delete buf_temp-no-route.
        end.
      end.
      for each buf_temp-smart-route where
              buf_temp-smart-route.db-num = integer(buf_temp-cmd.db-list):
        delete buf_temp-smart-route.
      end.
    end.
    v-is-empty = no.
    run is-almost-empty in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code
                                      ,output v-is-empty) no-error.
    if v-is-empty then do:
      run delete-command in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code ).
    end.
    if not v-is-empty and not mode-erprn then do:
      run send-command in v-cmd-proc-handle
        ( input buf_temp-cmd.cmd-code
          ,input buf_temp-cmd.db-list
          ) no-error .
      if error-status :error then do:
        delete procedure v-cmd-proc-handle .
        undo _main, return error substitute("&1 &2 &3&4Ошибка при отправке в новости команды с кодом &5 &8&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,v-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ,(if buf_temp-cmd.db-list = '':u then '':u else substitute(" - БД № &1", buf_temp-cmd.db-list))
                                            ).
      end.
    end.
  end.
  case p-cmd-doc-type:
    when 'sale-close':U
    or
    when 'trn-doc-close':U
    then do:
      define variable v-deleted as logical no-undo .
      if p-step = 1
      and g#db-num = 0
      then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input p-cmd-doc-code ,
                        input 'need-saledc':U ,
                       output v-deleted ) no-error .
       end.
    end.
    when 'sale-delete':U
    or
    when 'trn-doc-delete':U
    then do:
      if p-step = 1
      and g#db-num = 0
      then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-cmd-doc-code ,
                       input 'need-saledc':U ,
                       input string(1) ) no-error .
       end.
    end.
    otherwise do:
    end.
  end case.
  if valid-handle(v-cmd-proc-handle) then do:
    delete procedure v-cmd-proc-handle .
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Данные по ДК: &1 ЗАВЕРШЕНО ", p-cmd-doc-code)) no-error .
end.
procedure write-to-log :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.
end procedure.
procedure proc-verify-d-card :
define input parameter p-rec-name as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-dt-code as integer no-undo .
define output parameter p-type as character no-undo .
define output parameter p-emitent-host-code as integer no-undo .
define output parameter p-dtm-code as integer no-undo .
define variable v-call#-id as integer no-undo .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_temp-prop-ref for temp-prop-ref .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_prop-ref for ub.prop-ref.
do
on error undo, return error
:
find first buf_temp-d-card no-lock where
        buf_temp-d-card.d-card = p-d-card no-error .
if not available buf_temp-d-card then do:
  find first buf_Dis-card no-lock where
            buf_Dis-card.d-card = p-d-card no-error.
  if not available buf_Dis-card
  then do:
    if p-cmd-doc-type = 'sale-xml-import':U then return.
    undo, return error substitute("Ошибка при поиске ДК &1:Получена запись таблицы &2 для этой карты"
                                      ,p-d-card
                                      ,p-rec-name
                                      ).
  end.
  assign
  p-type = buf_dis-card.type
  p-emitent-host-code = buf_dis-card.emitent-host-code
  .
end.
else do:
  assign
  p-type = buf_temp-d-card.type
  p-emitent-host-code = buf_temp-d-card.emitent-host-code
  .
end.
if p-dt-code <> -1 then do:
  find first buf_temp-prop-ref no-lock where
            buf_temp-prop-ref.dt-code = p-dt-code no-error.
  if not available buf_temp-prop-ref then do:
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = p-dt-code no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Ошибка при поиске ДК &1:Получена запись таблицы &2 для этой карты&3Неизвестный срез/итог &4"
                                        ,p-d-card
                                        ,p-rec-name
                                        ,chr(10)
                                        ,p-dt-code
                                        ).
    end.
    create buf_temp-prop-ref.
    buffer-copy buf_prop-ref to buf_temp-prop-ref.
  end.
  p-dtm-code  = buf_temp-prop-ref.dtm-code.
  v-call-id = substitute("&2&1&3&1&4&1&5&1&6&1&7"
                        , chr(3)
                        , 'dis-card-type':U
                        , p-emitent-host-code
                        , p-type
                        , 0
                        , '':U
                        , 0).
end.
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
procedure cb_create-dc-list :
define input parameter p-bh as handle no-undo .
define variable v-dch as handle no-undo .
do
on error undo, return error return-value
:
end.
end procedure.
