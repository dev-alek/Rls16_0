DEFINE BUFFER locked_ext-system FOR ext-system.
DEFINE TEMP-TABLE tt-ext-system NO-UNDO LIKE ext-system.
DEFINE TEMP-TABLE tt-ext-system-attr NO-UNDO LIKE ext-system-attr.
define input parameter parparentproc        as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input-output parameter p-esys-id     as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define output parameter p-success           as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Редактирование записи внешней подсистемы с типом специальна ".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure oxmlext-create :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-esys-id           as integer          no-undo.
    define variable v-today     as date         no-undo.
    define variable v-time      as integer      no-undo.
    define variable v-userid    as character    no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run oxmlext-esys-id in this-procedure (
        output p-esys-id
    ).
    run get-userid in p-mainmenu-handle (
        output v-userid
    ).
    create buf_ext-system.
    assign
        buf_ext-system.esys-id                          = p-esys-id
        buf_ext-system.db-num                           = p-current-db-num
        buf_ext-system.esys-date-change                 = v-today
        buf_ext-system.esys-chk-ingr-imp                = no
        buf_ext-system.esys-chk-seq-imp                 = no
        buf_ext-system.esys-date-change-attr            = v-today
        buf_ext-system.esys-date-change-exp             = v-today
        buf_ext-system.esys-date-change-imp             = v-today
        buf_ext-system.esys-db-num-exp                  = p-current-db-num
        buf_ext-system.esys-db-num-imp                  = p-current-db-num
        buf_ext-system.esys-des                         = ""
        buf_ext-system.esys-file-chk-ing-imp            = "":U
        buf_ext-system.esys-have-export                 = no
        buf_ext-system.esys-have-import                 = no
        buf_ext-system.esys-have-proc-chk-ing-imp       = no
        buf_ext-system.esys-last-pack                   = 0
        buf_ext-system.esys-name                        = "<Новая внешняя система>"
        buf_ext-system.esys-num-days-keep-exp           = 0
        buf_ext-system.esys-num-days-keep-imp           = 0
        buf_ext-system.esys-proc-chk-ing-imp            = "":U
        buf_ext-system.esys-send-news-exp               = no
        buf_ext-system.esys-send-news-imp               = no
        buf_ext-system.esys-status                      = integer( '-1':U )
        buf_ext-system.esys-work-update                 = no
        buf_ext-system.esys-creid                       = v-userid
        buf_ext-system.esys-sys-date                    = v-today
        buf_ext-system.esys-sys-time-int                = v-time
        buf_ext-system.esys-sys-time                    = string( v-time, "HH:MM:SS" )
        buf_ext-system.esys-user-name                   = v-userid
        buf_ext-system.esys-user-db-num                 = p-current-db-num
    .
end.
end procedure.
procedure oxmlext-start-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 20
    then do:
        assign
            buf_ext-system.esys-status = 21
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 1
        .
    end.
end.
end procedure.
procedure oxmlext-stop-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 21
    then do:
        assign
            buf_ext-system.esys-status = 20
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 0
        .
    end.
end.
end procedure.
procedure oxmlext-stop-import :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure oxmlext-stop-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ext-system-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
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
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
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
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
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
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-oxmlextd-can-change-imp       as logical      no-undo init yes.
define variable v-oxmlextd-can-change-exp       as logical      no-undo init yes.
define variable v-oxmlextd-can-change-db-exp    as logical no-undo .
define variable v-oxmlextd-can-change-db-imp    as logical no-undo .
define variable link-option as character no-undo .
define variable v-ii as integer no-undo.
define variable v-type as character no-undo.
define variable v-attr-code as character no-undo .
DEFINE MENU MENU-b-links
       MENU-ITEM m_thobj        LABEL "Соответствие объектов ВС объектам IBS TH"
       MENU-ITEM m_edoc-nn      LABEL "Контрагенты для обмена данными (по EDOC-NN)"
       MENU-ITEM m_exite-edi    LABEL "Контрагенты для обмена данными (по EDI)"
       MENU-ITEM m_locks        LABEL "Блокирующие связи".
DEFINE BUTTON b-db-export
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-db-import
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-links
     LABEL "Связи"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-cert-file-ext AS CHARACTER FORMAT "X(4)"
     LABEL "Расширение в имени файла с ЭЦП"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "p7s","p7c"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE cb-cert-repository AS integer FORMAT ">>9"
     LABEL "Хранилище сертификатов"
     VIEW-AS COMBO-BOX INNER-LINES 2
     list-item-pairs
      "Личное хранилище пользователя",0,
      "Локальный компьютер",1
     DROP-DOWN-LIST
     SIZE 35 BY 1 no-undo init 0.
DEFINE VARIABLE f-exp-db-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE f-ftp-ip AS CHARACTER FORMAT "X(256)":U
     LABEL "FTP"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-ftp-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 TOOLTIP "Путь (от HOME-директории)" NO-UNDO.
DEFINE VARIABLE f-ftp-path-in AS CHARACTER FORMAT "X(256)":U
     LABEL "Вход."
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 TOOLTIP "Папка для входящих сообщений" NO-UNDO.
DEFINE VARIABLE f-ftp-path-out AS CHARACTER FORMAT "X(256)":U
     LABEL "Исход."
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 TOOLTIP "Папка для исходящих сообщений" NO-UNDO.
DEFINE VARIABLE f-imp-db-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE f-login AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-password AS CHARACTER FORMAT "X(24)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cert-sign-issuer AS CHARACTER FORMAT "X(256)":U
     LABEL "Издатель сертификата"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cert-sign-subject AS CHARACTER FORMAT "X(256)":U
     LABEL "Владелец сертификата (~"Субъект~")"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE FI-delivery-method AS CHARACTER FORMAT "X(256)":U INITIAL "Метод доставки:"
     VIEW-AS FILL-IN
     SIZE 15.6 BY 1 NO-UNDO.
DEFINE VARIABLE fi-des-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание:"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY .67
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Условия переформирования пакетов:"
      VIEW-AS TEXT
     SIZE 36 BY .67 NO-UNDO.
DEFINE VARIABLE l-save-oxml-pck AS CHARACTER FORMAT "X(256)":U INITIAL "дн."
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.6 BY 11.48.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12.6 BY 1.24
     BGCOLOR 8 FGCOLOR 8 .
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48 BY 6.48.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12.6 BY 1.24
     BGCOLOR 8 FGCOLOR 8 .
DEFINE VARIABLE t-delete-pck-on AS LOGICAL INITIAL no
     LABEL "Удал. ф-лы из HEAP"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY 1.1 NO-UNDO.
DEFINE VARIABLE T-exp-conf-wait AS LOGICAL INITIAL no
     LABEL "Ждет подтв. после экспорта"
     VIEW-AS TOGGLE-BOX
     SIZE 31.6 BY 1.1 NO-UNDO.
DEFINE VARIABLE T-imp-conf-send AS LOGICAL INITIAL no
     LABEL "Посылает подтв. после импорта"
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY 1.1 NO-UNDO.
DEFINE VARIABLE tg-cert-sign AS LOGICAL INITIAL no
     LABEL "Использовать электронную подпись"
     VIEW-AS TOGGLE-BOX
     SIZE 46 BY .81 NO-UNDO.
DEFINE VARIABLE f-proxy-addres AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес прокси-сервера"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 TOOLTIP "Адрес прокси-сервера в формате <IP>:<Port>" NO-UNDO.
DEFINE VARIABLE f-proxy-login AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-proxy-password AS CHARACTER FORMAT "X(256)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN NATIVE
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-proxy-password-screen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-diadoc-user AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин Диадок"
     VIEW-AS FILL-IN
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-diadoc-pwd AS CHARACTER FORMAT "X(256)":U
     LABEL "Пароль Диадок"
     VIEW-AS FILL-IN
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-diadoc-pwd-screen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-diadoc-addres AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес Диадок"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 NO-UNDO.
DEFINE VARIABLE f-diadoc-key AS CHARACTER FORMAT "X(256)":U
     LABEL "Ключ разработчика"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 NO-UNDO.
DEFINE VARIABLE f-diadoc-lastload AS date FORMAT "99/99/9999":U
     LABEL "Последнего загруженного документа"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE t-diadoc-ssl AS LOGICAL
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-proxy-ssl AS LOGICAL
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE f-host-code AS integer FORMAT ">>>>>>>>9":U
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE BUTTON b-host-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE f-server-addres AS CHARACTER FORMAT "X(256)":U
     LABEL "URL"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 TOOLTIP "Адрес точки подключения к ИС МОТП" NO-UNDO.
DEFINE VARIABLE f-obj AS character FORMAT "X(15)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
define variable e-mail-list as character format "X(1000)":U
     label "Список eMail"
     view-as editor
     size 50 by 3 no-undo .
DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE QUERY Dialog-Frame FOR
      tt-ext-system SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-links AT ROW 1 COL 26 WIDGET-ID 24
     b-help AT ROW 1 COL 95
     tt-ext-system.esys-id AT ROW 2.24 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     fi-des-label AT ROW 2.24 COL 51 NO-LABEL
     tt-ext-system.esys-des AT ROW 2.24 COL 61.6 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 34.6 BY 2
     tt-ext-system.esys-type AT ROW 3.57 COL 11 COLON-ALIGNED WIDGET-ID 64
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 10
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 34.6 BY 1
     tt-ext-system.esys-name AT ROW 4.91 COL 3
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN
          SIZE 34.6 BY 1
     f-ftp-ip AT ROW 5 COL 59.6 COLON-ALIGNED WIDGET-ID 48
     f-login AT ROW 6 COL 59.6 COLON-ALIGNED WIDGET-ID 50
     FI-delivery-method AT ROW 6.33 COL 2.8 NO-LABEL WIDGET-ID 42
     tt-ext-system.delivery-method AT ROW 6.33 COL 16.6 COLON-ALIGNED NO-LABEL WIDGET-ID 28
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Item 1",1,
                     "Item 2",2
          DROP-DOWN-LIST
          SIZE 29 BY 1
     f-password AT ROW 7 COL 59.6 COLON-ALIGNED WIDGET-ID 52 BLANK
     fi-screen-pass AT ROW 7.24 COL 59.6 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     f-ftp-path AT ROW 8 COL 59.6 COLON-ALIGNED WIDGET-ID 56
     f-ftp-path-in AT ROW 9 COL 59.6 COLON-ALIGNED WIDGET-ID 66
     tt-ext-system.esys-have-export AT ROW 9.19 COL 3.6
          LABEL "Экспорт"
          VIEW-AS TOGGLE-BOX
          SIZE 10.6 BY .81
     f-ftp-path-out AT ROW 10 COL 59.6 COLON-ALIGNED WIDGET-ID 68
     tt-ext-system.esys-db-num-exp AT ROW 10.52 COL 4.6 COLON-ALIGNED
          LABEL "БД" FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     b-db-export AT ROW 10.52 COL 12 WIDGET-ID 16
     f-exp-db-name AT ROW 10.52 COL 14 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     t-delete-pck-on AT ROW 12 COL 55 WIDGET-ID 62
     tt-ext-system.save-days-pck-num AT ROW 12 COL 82.6 COLON-ALIGNED WIDGET-ID 58
          LABEL "через"
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1.1
     tt-ext-system.esys-send-news-exp AT ROW 12.24 COL 6.6
          LABEL "Отправлять в новости"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY .81
     T-exp-conf-wait AT ROW 13.24 COL 6.6 WIDGET-ID 30
     tt-ext-system.esys-have-import AT ROW 14 COL 52 WIDGET-ID 6
          LABEL "Импорт"
          VIEW-AS TOGGLE-BOX
          SIZE 10.6 BY .81
     tt-ext-system.esys-num-days-keep-exp AT ROW 14.52 COL 37 COLON-ALIGNED
          LABEL "Дней хранения пакетов" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-ext-system.esys-max-p-size AT ROW 15.76 COL 37 COLON-ALIGNED WIDGET-ID 40
          LABEL "Макс. размер пакета" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-ext-system.esys-db-num-imp AT ROW 16 COL 53 COLON-ALIGNED WIDGET-ID 10
          LABEL "БД" FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     b-db-import AT ROW 16 COL 60.6 WIDGET-ID 18
     f-imp-db-name AT ROW 16.1 COL 62.6 COLON-ALIGNED NO-LABEL WIDGET-ID 22
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-ext-system.esys-send-news-imp AT ROW 17.52 COL 55 WIDGET-ID 12
          LABEL "Отправлять в новости"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY .81
     tt-ext-system.max-p-queue AT ROW 18.24 COL 37 COLON-ALIGNED WIDGET-ID 34
          LABEL "Кол-во неподтв. пакетов" FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     T-imp-conf-send AT ROW 18.52 COL 55 WIDGET-ID 32
     tt-ext-system.max-p-time AT ROW 19.52 COL 40.2 COLON-ALIGNED WIDGET-ID 36
          LABEL "Время ожидания потверждения > (мин)"
          VIEW-AS FILL-IN
          SIZE 9 BY 1 TOOLTIP "max время, черепз котор. должен отправляться очередной пакет"
     tg-cert-sign AT ROW 21.24 COL 4 WIDGET-ID 70
     fi-cert-sign-issuer AT ROW 22.19 COL 38 COLON-ALIGNED WIDGET-ID 72
     fi-cert-sign-subject AT ROW 23.38 COL 38 COLON-ALIGNED WIDGET-ID 74
     cb-cert-file-ext AT ROW 24.57 COL 38 COLON-ALIGNED WIDGET-ID 76
     cb-cert-repository AT ROW 25.7 COL 38 COLON-ALIGNED WIDGET-ID 86
     l-save-oxml-pck AT ROW 12.24 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     FILL-IN-4 AT ROW 17.24 COL 2.4 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     RECT-1 AT ROW 9.52 COL 1.6
     RECT-2 AT ROW 9 COL 2.6
     RECT-3 AT ROW 14.52 COL 50 WIDGET-ID 8
     RECT-4 AT ROW 13.76 COL 51.6 WIDGET-ID 14
     SPACE(34.39) SKIP(10.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешняя подсистема Open XML"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
define frame motp-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ext-system.esys-id AT ROW 2 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-ext-system.esys-type AT ROW 2.08 COL 58.63 COLON-ALIGNED WIDGET-ID 58
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 35.63 BY 1
     tt-ext-system.esys-name AT ROW 3.5 COL 3
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN
          SIZE 29 BY 1
     f-host-code at row 5 col 3
     b-host-code at row 5 col 23
     f-server-addres at row 6 col 3
     f-obj at row 7 col 3
     b-obj at row 7 col 30
     e-mail-list at row 8 col 3
     f-proxy-addres at row 12 col 3
     f-proxy-login at row 13 col 3
     f-proxy-password at row 14 col 3 blank
     f-proxy-password-screen at row 14 col 3  no-label
     t-proxy-ssl at row 15.1 col 14 no-label
     "SSL прокси:" at row 15 col 3 view-as text size 11 by 1
     SPACE(83.11) SKIP(5.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
define frame diadoc-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ext-system.esys-id AT ROW 2 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-ext-system.esys-type AT ROW 2.08 COL 58.63 COLON-ALIGNED WIDGET-ID 58
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 35.63 BY 1
     tt-ext-system.esys-name AT ROW 3.5 COL 14
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN
          SIZE 29 BY 1
     f-host-code at row 5 col 17
     b-host-code at row 5 col 40
     f-obj at row 6.5 col 16
     b-obj at row 6.5 col 40
     f-diadoc-addres at row 8 col 10
     f-diadoc-user at row 9.5 col 10
     f-diadoc-pwd at row 11 col 9  blank
     f-diadoc-pwd-screen at row 10.9 col 9.4  no-label
     f-diadoc-key at row 12.5 col 5
     f-proxy-addres at row 14 col 2
     f-proxy-login at row 15.5 col 17
     f-proxy-password at row 17 col 16  blank
     f-proxy-password-screen at row 16.9 col 16.4  no-label
     f-diadoc-lastload at row 18.5 col 10
     t-diadoc-ssl at row 20.1 col 28 no-label
     "Без проверки шифрования:" at row 20 col 3 view-as text size 24 by 1
     SPACE(83.11) SKIP(5.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.
ASSIGN
       f-exp-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-imp-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON ANY-KEY OF f-diadoc-pwd IN FRAME diadoc-Frame
DO:
    assign
    f-diadoc-pwd-screen :screen-value = fill('*':u, length(f-diadoc-pwd :screen-value )).
END.
ON VALUE-CHANGED OF f-diadoc-pwd IN FRAME diadoc-Frame
DO:
  assign
    f-diadoc-pwd-screen :screen-value = fill('*':u, length(f-diadoc-pwd :screen-value )).
  .
END.
ON ANY-KEY OF f-proxy-password IN FRAME diadoc-Frame
DO:
    assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value )).
END.
ON VALUE-CHANGED OF f-proxy-password IN FRAME diadoc-Frame
DO:
  assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value )).
  .
END.
ON ANY-KEY OF f-proxy-password IN FRAME motp-frame
DO:
    assign
      f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value ))
    .
END.
ON VALUE-CHANGED OF f-proxy-password IN FRAME motp-frame
DO:
  assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value ))
  .
END.
ON CHOOSE OF b-db-export IN FRAME Dialog-Frame
DO:
define variable v-rid as recid no-undo.
define buffer buf_db for ub.db.
   run adm/dbs.w ( INPUT parparentproc
                  ,INPUT 'ПРОСМОТР':U
                  ,OUTPUT v-rid) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN return no-apply.
    FIND FIRST buf_db NO-LOCK WHERE
           recid(buf_db) = v-rid no-error.
   if available buf_db then do:
      assign
      tt-ext-system.esys-db-num-exp = buf_db.db-num
      f-exp-db-name = buf_db.db-name.
      display
      tt-ext-system.esys-db-num-exp
      f-exp-db-name
      with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-db-import IN FRAME Dialog-Frame
DO:
  define variable v-rid as recid no-undo.
define buffer buf_db for ub.db.
   run adm/dbs.w ( INPUT parparentproc
                  ,INPUT 'ПРОСМОТР':U
                  ,OUTPUT v-rid) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN no-apply.
    FIND FIRST buf_db NO-LOCK WHERE
           recid(buf_db) = v-rid no-error.
   if available buf_db then do:
      assign
      tt-ext-system.esys-db-num-imp = buf_db.db-num
      f-imp-db-name = buf_db.db-name
      .
      display
      tt-ext-system.esys-db-num-imp
      f-imp-db-name
      with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
   run proc-save in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.
ON CHOOSE OF b-exit IN FRAME motp-Frame
DO:
   run proc-save-motp in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.
ON CHOOSE OF b-exit IN FRAME diadoc-Frame
DO:
   run proc-save-diadoc in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.
ON CHOOSE OF b-links IN FRAME Dialog-Frame
DO:
IF link-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if link-option = "":U then do:
      return no-apply.
end.
run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    link-option = '':U.
    RETURN NO-APPLY.
END.
link-option = '':U.
END.
on choose of b-host-code in frame motp-frame
do :
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  DISPLAY
    f-host-code
  WITH FRAME motp-frame.
end .
on choose of b-host-code in frame diadoc-frame
do :
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  DISPLAY
    f-host-code
  WITH FRAME diadoc-frame.
end .
on choose of b-obj in frame motp-frame
do :
  define variable v-rid-list as character no-undo .
  define variable v-rid-rec  as recid no-undo .
  define buffer buf_shop for ub.shop .
  v-rid-list = "" .
  run adm/shops.w ( input parparentproc
                   ,input "b-sel"
                   ,input-output v-rid-list
                   ,no ).
  if v-rid-list = "":U then return.
  v-rid-rec = integer(v-rid-list) no-error .
  find first buf_shop no-lock where recid(buf_shop) = v-rid-rec no-error .
  if available buf_shop then f-obj:screen-value = 'маг':U + string(buf_shop.obj-code) .
  assign f-obj .
end .
on value-changed of f-obj in frame motp-frame
do :
  assign f-obj .
end .
on choose of b-obj in frame diadoc-frame
do :
  define variable v-rid-list as character no-undo .
  define variable v-rid-rec  as recid no-undo .
  define buffer buf_shop for ub.shop .
  v-rid-list = "" .
  run adm/shops.w ( input parparentproc
                   ,input "b-sel"
                   ,input-output v-rid-list
                   ,no ).
  if v-rid-list = "":U then return.
  v-rid-rec = integer(v-rid-list) no-error .
  find first buf_shop no-lock where recid(buf_shop) = v-rid-rec no-error .
  if available buf_shop then f-obj:screen-value = 'маг':U + string(buf_shop.obj-code) .
  assign f-obj .
end .
on value-changed of f-obj in frame diadoc-frame
do :
  assign f-obj .
end .
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON VALUE-CHANGED OF tt-ext-system.delivery-method IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-ext-system.delivery-method.
  run proc-value-change-method in this-procedure ( input tt-ext-system.delivery-method) no-error.
END.
ON CHOOSE OF b-quit IN FRAME motp-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON CHOOSE OF b-quit IN FRAME diadoc-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON VALUE-CHANGED OF tt-ext-system.esys-have-export IN FRAME Dialog-Frame
DO:
    assign
        tt-ext-system.esys-have-export
    .
    run manage-export in this-procedure (
        input tt-ext-system.esys-have-export
    ).
END.
ON VALUE-CHANGED OF tt-ext-system.esys-have-import IN FRAME Dialog-Frame
DO:
    assign
        tt-ext-system.esys-have-import
    .
    run manage-import in this-procedure (
        input tt-ext-system.esys-have-import
    ).
END.
ON VALUE-CHANGED OF tt-ext-system.esys-name IN FRAME Dialog-Frame
DO:
    ASSIGN
  tt-ext-system.esys-name.
END.
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME Dialog-Frame
DO:
    ASSIGN
  tt-ext-system.esys-type.
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME motp-Frame
DO:
  ASSIGN
    tt-ext-system.esys-type
  .
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME diadoc-Frame
DO:
  ASSIGN
    tt-ext-system.esys-type
  .
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON ANY-KEY OF f-password IN FRAME Dialog-Frame
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.
ON VALUE-CHANGED OF f-password IN FRAME Dialog-Frame
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.
ON CHOOSE OF MENU-ITEM m_edoc-nn
DO:
    ASSIGN
  link-option = "edoc-nn".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_exite-edi
DO:
  ASSIGN
  link-option = "exite-edi".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_locks
DO:
      ASSIGN
  link-option = "locks".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_thobj
DO:
    ASSIGN
  link-option = "thobjs".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.
ON VALUE-CHANGED OF t-delete-pck-on IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-delete-pck-on.
  RUN manage-t-delete-pck-on ( t-delete-pck-on) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF tg-cert-sign IN FRAME Dialog-Frame
DO:
  assign tg-cert-sign .
  run proc-value-changed-cert-sign in this-procedure (input tg-cert-sign) no-error .
  if error-status:error then return no-apply .
END.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if not (p-mode = 'ДОБАВЛЕНИЕ':U
           or p-mode = 'ПРОСМОТР':U
           or p-mode = 'ИЗМЕНЕНИЕ':U) then do:
      message
      substitute("Неправильное значение параметра p-mode = &1", p-mode)
      view-as alert-box error.
      undo, return error.
   end.
// if p-mode <> {&lookup} and v-cntxt-db-num > 0 then do: - 29/VIII-2018 заменено на ibs.th.gbl.gbl-var:g#db-num
   if p-mode <> 'ПРОСМОТР':U and ibs.th.gbl.gbl-var:g#db-num > 0 then do:
      message
      substitute("Нельзя редактировать или добавлять специальную внешнюю систему в УБД")
      view-as alert-box error.
      undo, return error.
   end.
   case p-mode:
    when 'ПРОСМОТР':U then do:
      find first locked_ext-system no-lock where
             locked_ext-system.esys-id = p-esys-id
       and locked_ext-system.db-num = p-db-num no-error.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
         do transaction:
        find first locked_ext-system exclusive-lock where
           locked_ext-system.esys-id = p-esys-id
      and locked_ext-system.db-num = p-db-num no-error.
      end.
     end.
   end case.
    create tt-ext-system.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      assign
      tt-ext-system.db-num = 0
      tt-ext-system.esys-send-news-exp = yes
      tt-ext-system.esys-send-news-imp = yes
      tt-ext-system.esys-num-days-keep-imp = 0
      tt-ext-system.esys-db-num-exp = 0
      tt-ext-system.esys-db-num-imp = 0
      tt-ext-system.esys-name = "<Новая внешняя система>"
      tt-ext-system.esys-max-p-size = 1000
      .
    end.
    else do:
       buffer-copy  locked_ext-system to tt-ext-system.
       for each tt-ext-system-attr:
         delete tt-ext-system-attr.
       end.
       do v-ii = 1 to num-entries('FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U):
         v-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U) .
         create tt-ext-system-attr.
         assign
         tt-ext-system-attr.esys-id = tt-ext-system.esys-id
         tt-ext-system-attr.db-num = tt-ext-system.db-num
         tt-ext-system-attr.esya-attr-code = v-attr-code
          .
         run ext-system-attr-value (
                                      input  tt-ext-system.esys-id
                                     ,input  tt-ext-system.db-num
                                     ,input  v-attr-code
                                     ,output tt-ext-system-attr.esya-attr-value
                                     ,output v-type) .
          release tt-ext-system-attr.
       end.
    end.
  if tt-ext-system.esys-type = integer('11':U)
  then do :
    run motp-enable in this-procedure .
  end .
  else do :
     if tt-ext-system.esys-type = integer('12':U)
     then do :
        run diadoc-enable in this-procedure .
     end .
     else do :
        run myenable in this-procedure .
     end.
  end .
  WAIT-FOR GO OF FRAME dialog-frame or go OF FRAME motp-frame or go OF FRAME diadoc-frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-ext-system SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fi-des-label f-ftp-ip f-login FI-delivery-method f-password
          fi-screen-pass f-ftp-path f-ftp-path-in f-ftp-path-out f-exp-db-name
          t-delete-pck-on T-exp-conf-wait f-imp-db-name T-imp-conf-send
          tg-cert-sign fi-cert-sign-subject fi-cert-sign-issuer cb-cert-file-ext
          cb-cert-repository l-save-oxml-pck FILL-IN-4
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ext-system THEN
    DISPLAY tt-ext-system.esys-id tt-ext-system.esys-des tt-ext-system.esys-type
          tt-ext-system.esys-name tt-ext-system.delivery-method
          tt-ext-system.esys-have-export tt-ext-system.esys-db-num-exp
          tt-ext-system.save-days-pck-num tt-ext-system.esys-send-news-exp
          tt-ext-system.esys-have-import tt-ext-system.esys-num-days-keep-exp
          tt-ext-system.esys-max-p-size tt-ext-system.esys-db-num-imp
          tt-ext-system.esys-send-news-imp tt-ext-system.max-p-queue
          tt-ext-system.max-p-time
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-links b-help RECT-1 RECT-2 RECT-3 RECT-4
         tt-ext-system.esys-id tt-ext-system.esys-des tt-ext-system.esys-type
         tt-ext-system.esys-name f-ftp-ip f-login FI-delivery-method
         tt-ext-system.delivery-method f-password f-ftp-path f-ftp-path-in
         tt-ext-system.esys-have-export f-ftp-path-out b-db-export
         f-exp-db-name t-delete-pck-on tt-ext-system.save-days-pck-num
         T-exp-conf-wait tt-ext-system.esys-have-import
         tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size
         b-db-import f-imp-db-name tt-ext-system.max-p-queue T-imp-conf-send
         tt-ext-system.max-p-time tg-cert-sign fi-cert-sign-subject
         fi-cert-sign-issuer cb-cert-file-ext l-save-oxml-pck FILL-IN-4
         cb-cert-repository
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE manage-delete-pck-on :
DEFINE INPUT PARAMETER t-delete-pck-on AS LOGICAL NO-UNDO.
CASE t-delete-pck-on:
    WHEN YES THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN
      ENABLE
      tt-ext-system.save-days-pck-num
      WITH FRAME Dialog-Frame.
      if tt-ext-system.save-days-pck-num < 20 then tt-ext-system.save-days-pck-num = 20.
      DISPLAY
      tt-ext-system.save-days-pck-num
      l-save-oxml-pck
      WITH FRAME Dialog-Frame.
    END.
    WHEN NO THEN DO:
        DISABLE
        tt-ext-system.save-days-pck-num
        WITH FRAME Dialog-Frame.
        HIDE
        tt-ext-system.save-days-pck-num
        l-save-oxml-pck
        IN FRAME Dialog-Frame.
    END.
END CASE.
END PROCEDURE.
PROCEDURE manage-exp-conf-wait :
DEFINE input parameter p-exp-conf-wait    as integer          no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-exp-conf-wait = integer('1':U)
    then do:
        enable
        tt-ext-system.max-p-queue
        tt-ext-system.max-p-time
        .
    end.
    else do:
        disable
        tt-ext-system.max-p-queue
        tt-ext-system.max-p-time
        .
        assign
        tt-ext-system.max-p-time = 0
        tt-ext-system.max-p-queue = 1000
        .
    end.
    display
    tt-ext-system.max-p-queue
    tt-ext-system.max-p-time
    .
end.
END PROCEDURE.
PROCEDURE manage-export :
define input parameter p-have-export    as logical          no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-have-export = yes
    then do:
      enable
      tt-ext-system.esys-num-days-keep-exp
      t-exp-conf-wait when tt-ext-system.delivery-method <> integer('11':U)
      tt-ext-system.esys-max-p-size
      b-db-export
      .
      assign
      tt-ext-system.esys-send-news-exp = yes
      .
    end.
    else do:
        disable
        b-db-export
        tt-ext-system.esys-num-days-keep-exp
        tt-ext-system.esys-max-p-size
        t-exp-conf-wait
       .
        assign
        tt-ext-system.esys-send-news-exp = no
        tt-ext-system.esys-max-p-size = (if tt-ext-system.esys-max-p-size = 0
                                         then 1000
                                         else tt-ext-system.esys-max-p-size)
        t-exp-conf-wait = no
        .
    end.
    display
    tt-ext-system.esys-send-news-exp
    tt-ext-system.esys-max-p-size
    .
    tt-ext-system.exp-conf-wait = (if t-exp-conf-wait
                                   then integer('1':U)
                                   else integer('0':U)
                                   ).
    run manage-exp-conf-wait in this-procedure ( input tt-ext-system.exp-conf-wait).
end.
END PROCEDURE.
PROCEDURE manage-import :
define input parameter p-have-import    as logical          no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-have-import = yes
    then do:
        enable
        b-db-import
        t-imp-conf-send when tt-ext-system.delivery-method <> integer('11':U)
        .
        assign
        tt-ext-system.esys-send-news-imp = yes
        .
    end.
    else do:
        disable
        b-db-import
        t-imp-conf-send
        .
        assign
        tt-ext-system.esys-send-news-imp = no
        t-imp-conf-send = no
        .
    end.
    display
    tt-ext-system.esys-send-news-imp.
    tt-ext-system.imp-conf-send = (if t-imp-conf-send
                                   then integer('1':U)
                                   else integer('0':U)
                                   ).
end.
END PROCEDURE.
PROCEDURE manage-t-delete-pck-on :
DEFINE INPUT PARAMETER t-save-oxml-pck AS LOGICAL NO-UNDO.
CASE t-save-oxml-pck:
    WHEN YES THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN
      ENABLE
      tt-ext-system.save-days-pck-num
      WITH FRAME Dialog-Frame.
      if tt-ext-system.save-days-pck-num < 20 then tt-ext-system.save-days-pck-num = 20.
      DISPLAY
      tt-ext-system.save-days-pck-num
      WITH FRAME Dialog-Frame.
    END.
    WHEN NO THEN DO:
        DISABLE
        tt-ext-system.save-days-pck-num
        WITH FRAME Dialog-Frame.
        HIDE
        tt-ext-system.save-days-pck-num
        IN FRAME Dialog-Frame.
    END.
END CASE.
END PROCEDURE.
procedure MOTP-Enable :
  DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ii AS integer NO-UNDO.
  define buffer buf_db for ub.db.
  do v-ii = 1 to num-entries('1,2,3,4,5,6,7,8,9,10,11,12':U):
      assign
    tt-ext-system.esys-type:list-item-pairs in frame Motp-frame =
    (if v-ii = 1
    then (entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
    else (tt-ext-system.esys-type:list-item-pairs + chr(44) +
           entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
    )
    .
  end.
  for each tt-ext-system-attr:
    case tt-ext-system-attr.esya-attr-code:
      when 'host-code':U then do:
        assign f-host-code = integer(tt-ext-system-attr.esya-attr-value) .
      end.
      when 'obj':U then do:
        assign f-obj = tt-ext-system-attr.esya-attr-value .
      end.
      when 'server-addr':U then do:
        assign f-server-addres = tt-ext-system-attr.esya-attr-value.
      end.
      when 'proxy-addr':U then do:
        assign f-proxy-addres = tt-ext-system-attr.esya-attr-value .
      end.
      when 'proxy-login':U then do:
        assign f-proxy-login = tt-ext-system-attr.esya-attr-value .
      end.
      when 'proxy-pswd':U then do:
        assign f-proxy-password = tt-ext-system-attr.esya-attr-value .
      end.
      when 'proxy-ssl':U then do:
        assign t-proxy-ssl = logical(tt-ext-system-attr.esya-attr-value) .
      end.
      when 'mail-list':U then do:
        assign e-mail-list = tt-ext-system-attr.esya-attr-value .
      end.
    end case.
  end.
  ASSIGN
   f-proxy-password-screen:WIDTH-CHARS IN FRAME motp-frame  = f-proxy-password:WIDTH-CHARS IN FRAME motp-frame  - 0.5
   f-proxy-password-screen:HEIGHT-CHARS IN FRAME motp-frame  = f-proxy-password:HEIGHT-CHARS IN FRAME motp-frame  - 0.6
   f-proxy-password-screen:row IN FRAME motp-frame  = f-proxy-password:row IN FRAME motp-frame  + 0.2
   f-proxy-password-screen:COL IN FRAME motp-frame  = f-proxy-password:col IN FRAME motp-frame  + 0.2
  .
  f-proxy-password-screen  = fill('*':u, length(f-proxy-password )).
  DISPLAY
    tt-ext-system.esys-id
    tt-ext-system.esys-name
    tt-ext-system.esys-type
    f-host-code
    f-server-addres
    f-obj
    f-proxy-addres
    f-proxy-login
    f-proxy-password
    f-proxy-password-screen
    t-proxy-ssl
    e-mail-list
  WITH FRAME MOTP-frame .
  ENABLE
    b-exit when p-mode <> 'ПРОСМОТР':U
    b-quit
    b-host-code when p-mode <> 'ПРОСМОТР':U
    f-obj when p-mode <> 'ПРОСМОТР':U
    b-obj when p-mode <> 'ПРОСМОТР':U
    tt-ext-system.esys-name when p-mode <> 'ПРОСМОТР':U
    tt-ext-system.esys-type when p-mode <> 'ПРОСМОТР':U
    f-server-addres when p-mode <> 'ПРОСМОТР':U
    f-proxy-addres when p-mode <> 'ПРОСМОТР':U
    f-proxy-login when p-mode <> 'ПРОСМОТР':U
    f-proxy-password when p-mode <> 'ПРОСМОТР':U
    f-proxy-password-screen when p-mode <> 'ПРОСМОТР':U
    t-proxy-ssl when p-mode <> 'ПРОСМОТР':U
    e-mail-list when p-mode <> 'ПРОСМОТР':U
  WITH FRAME Motp-frame .
  view frame Motp-frame .
end procedure .
procedure Diadoc-Enable :
  DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ii AS integer NO-UNDO.
  define buffer buf_db for ub.db.
  do v-ii = 1 to num-entries('1,2,3,4,5,6,7,8,9,10,11,12':U):
      assign
    tt-ext-system.esys-type:list-item-pairs in frame diadoc-frame =
    (if v-ii = 1
    then (entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
    else (tt-ext-system.esys-type:list-item-pairs + chr(44) +
           entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
    )
    .
  end.
  for each tt-ext-system-attr:
    case tt-ext-system-attr.esya-attr-code:
      when 'obj':U then do:
        assign f-obj = tt-ext-system-attr.esya-attr-value .
      end.
      when 'host-code':U then do:
        assign f-host-code = integer(tt-ext-system-attr.esya-attr-value) .
      end.
      when 'diadoc-user':U then do:
        assign f-diadoc-user = tt-ext-system-attr.esya-attr-value .
      end.
      when 'diadoc-pwd':U then do:
        assign f-diadoc-pwd= tt-ext-system-attr.esya-attr-value .
      end.
      when 'server-addr':U then do:
        assign f-diadoc-addres = tt-ext-system-attr.esya-attr-value.
      end.
      when 'diadoc-key':U then do:
        assign f-diadoc-key = tt-ext-system-attr.esya-attr-value .
      end.
      when 'diadoc-lastload':U then do:
        assign f-diadoc-lastload = date(tt-ext-system-attr.esya-attr-value) .
      end.
      when 'diadoc-ssl':U then do:
        assign t-diadoc-ssl = logical(tt-ext-system-attr.esya-attr-value) .
      end.
      when 'proxy-addr':U then do:
        assign f-proxy-addres = tt-ext-system-attr.esya-attr-value .
      end.
      when 'proxy-login':U then do:
        assign f-proxy-login = tt-ext-system-attr.esya-attr-value .
      end.
      when 'proxy-pswd':U then do:
        assign f-proxy-password = tt-ext-system-attr.esya-attr-value .
      end.
    end case.
  end.
  ASSIGN
 f-diadoc-pwd-screen:WIDTH-CHARS IN FRAME diadoc-frame  = f-diadoc-pwd:WIDTH-CHARS IN FRAME diadoc-frame  - 0.5
 f-diadoc-pwd-screen:HEIGHT-CHARS IN FRAME diadoc-frame  = f-diadoc-pwd:HEIGHT-CHARS IN FRAME diadoc-frame  - 0.6
 f-diadoc-pwd-screen:row IN FRAME diadoc-frame  = f-diadoc-pwd:row IN FRAME diadoc-frame  + 0.2
 f-diadoc-pwd-screen:COL IN FRAME diadoc-frame  = f-diadoc-pwd:col IN FRAME diadoc-frame  + 0.2
 .
 ASSIGN
 f-proxy-password-screen:WIDTH-CHARS IN FRAME diadoc-frame  = f-proxy-password:WIDTH-CHARS IN FRAME diadoc-frame  - 0.5
 f-proxy-password-screen:HEIGHT-CHARS IN FRAME diadoc-frame  = f-proxy-password:HEIGHT-CHARS IN FRAME diadoc-frame  - 0.6
 f-proxy-password-screen:row IN FRAME diadoc-frame  = f-proxy-password:row IN FRAME diadoc-frame  + 0.2
 f-proxy-password-screen:COL IN FRAME diadoc-frame  = f-proxy-password:col IN FRAME diadoc-frame  + 0.2
 .
 f-diadoc-pwd-screen      = fill('*':u, length(f-diadoc-pwd )).
 f-proxy-password-screen  = fill('*':u, length(f-proxy-password )).
  DISPLAY
    tt-ext-system.esys-id
    tt-ext-system.esys-name
    tt-ext-system.esys-type
    f-diadoc-user
    f-diadoc-pwd
    f-host-code
    f-obj
    f-diadoc-addres
    f-diadoc-key
    f-proxy-addres
    f-proxy-login
    f-proxy-password
    f-proxy-password-screen
    f-diadoc-pwd-screen
    f-diadoc-lastload
    t-diadoc-ssl
  WITH FRAME diadoc-frame .
  ENABLE
    b-exit when p-mode <> 'ПРОСМОТР':U
    b-quit
    tt-ext-system.esys-name when p-mode <> 'ПРОСМОТР':U
    tt-ext-system.esys-type when p-mode <> 'ПРОСМОТР':U
    f-diadoc-user           when p-mode <> 'ПРОСМОТР':U
    f-diadoc-pwd            when p-mode <> 'ПРОСМОТР':U
    f-diadoc-addres         when p-mode <> 'ПРОСМОТР':U
    f-diadoc-key            when p-mode <> 'ПРОСМОТР':U
    t-diadoc-ssl    when p-mode <> 'ПРОСМОТР':U
    f-proxy-addres          when p-mode <> 'ПРОСМОТР':U
    f-proxy-login           when p-mode <> 'ПРОСМОТР':U
    f-proxy-password        when p-mode <> 'ПРОСМОТР':U
    f-proxy-password-screen when p-mode <> 'ПРОСМОТР':U
    f-diadoc-pwd-screen     when p-mode <> 'ПРОСМОТР':U
    f-diadoc-lastload       when p-mode <> 'ПРОСМОТР':U
    f-host-code             when p-mode <> 'ПРОСМОТР':U
    b-host-code             when p-mode <> 'ПРОСМОТР':U
    f-obj                   when p-mode <> 'ПРОСМОТР':U
    b-obj                   when p-mode <> 'ПРОСМОТР':U
  WITH FRAME diadoc-frame .
  view frame diadoc-frame .
end procedure .
PROCEDURE MyEnable :
define variable v-list-item-pairs as character no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
define buffer buf_db for ub.db.
  v-list-item-pairs = "" .
do v-ii = 1 to num-entries('1,2,3,4,5,6,7,8,9,10,11,12':U):
  v-list-item-pairs =
  (if v-ii = 1
  then (entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
  else (v-list-item-pairs + chr(44) +
         entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
  )
  .
end.
  tt-ext-system.esys-type:list-item-pairs in frame Dialog-Frame = v-list-item-pairs .
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME Dialog-Frame = f-password:WIDTH-CHARS IN FRAME Dialog-Frame - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME Dialog-Frame = f-password:HEIGHT-CHARS IN FRAME Dialog-Frame - 0.6
 fi-screen-pass:row IN FRAME Dialog-Frame = f-password:row IN FRAME Dialog-Frame + 0.20
 fi-screen-pass:COL IN FRAME Dialog-Frame = f-password:col IN FRAME Dialog-Frame + 0.25
 .
for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when 'FTP':U       then f-ftp-ip       = tt-ext-system-attr.esya-attr-value.
     when 'Login':U    then f-login        = tt-ext-system-attr.esya-attr-value.
     when 'Password':U then f-password     = tt-ext-system-attr.esya-attr-value.
     when 'Path':U     then f-ftp-path     = tt-ext-system-attr.esya-attr-value.
     when 'IN-dir':U  then f-ftp-path-in  = tt-ext-system-attr.esya-attr-value.
     when 'OUT-dir':U then f-ftp-path-out = tt-ext-system-attr.esya-attr-value.
     when 'cert-sign':U         then tg-cert-sign = logical(tt-ext-system-attr.esya-attr-value) .
     when 'cert-sign-subject':U then fi-cert-sign-subject = tt-ext-system-attr.esya-attr-value.
     when 'cert-sign-issuer':U  then fi-cert-sign-issuer  = tt-ext-system-attr.esya-attr-value.
     when 'cert-file-ext':U     then cb-cert-file-ext     = tt-ext-system-attr.esya-attr-value.
     when 'cert-repository':U   then cb-cert-repository   = integer(tt-ext-system-attr.esya-attr-value).
  end case.
end.
DO v-ii = 1 TO NUM-ENTRIES('0,2,3,4,5,9,10,11':U):
    ASSIGN
    v-list-items = v-list-items + (IF v-ii = 1 THEN '' ELSE chr(44)) +
                entry (lookup (ENTRY(v-ii, '0,2,3,4,5,9,10,11':U), '0,2,3,4,5,9,10,11':U) + 1, ',' + 'Как в СПН,Не архивировать;FTP,Oracle Retail,Не архивировать(Панель Руководителя;DKLink),Exite-EDI,Контур.EDI,ЕГАИС,ERP 1С РН':U) + chr(44) + ENTRY(v-ii, '0,2,3,4,5,9,10,11':U)
    .
END.
ASSIGN
tt-ext-system.delivery-method:list-item-pairs IN FRAME Dialog-Frame = v-list-items.
DISPLAY
fi-des-label
fi-delivery-method
WITH FRAME Dialog-Frame.
if tt-ext-system.esys-db-num-exp >= 0 then do:
  find first buf_db no-lock where
            buf_db.db-num = tt-ext-system.esys-db-num-exp no-error.
  if available buf_db then do:
    f-exp-db-name = buf_db.db-name.
  end.
  else do:
    f-exp-db-name = chr(63).
  end.
end.
if tt-ext-system.esys-db-num-imp >= 0 then do:
  find first buf_db no-lock where
            buf_db.db-num = tt-ext-system.esys-db-num-imp no-error.
  if available buf_db then do:
    f-imp-db-name = buf_db.db-name.
  end.
  else do:
    f-imp-db-name = chr(63).
  end.
end.
assign
b-links:menu-mouse in frame Dialog-Frame = 1
t-exp-conf-wait = (tt-ext-system.exp-conf-wait = INTEGER('1':U))
t-imp-conf-send = (tt-ext-system.imp-conf-send = INTEGER('1':U))
t-delete-pck-on = (tt-ext-system.delete-pck-on = 1)
.
IF AVAILABLE tt-ext-system THEN
DISPLAY
tt-ext-system.esys-id
tt-ext-system.esys-name
tt-ext-system.esys-des
tt-ext-system.esys-have-export
tt-ext-system.esys-db-num-exp
tt-ext-system.esys-send-news-exp
tt-ext-system.esys-num-days-keep-exp
tt-ext-system.esys-have-import
tt-ext-system.esys-send-news-imp
tt-ext-system.esys-db-num-imp
tt-ext-system.max-p-queue
tt-ext-system.max-p-time
tt-ext-system.esys-max-p-size
tt-ext-system.esys-type
f-exp-db-name
f-imp-db-name
t-exp-conf-wait
t-imp-conf-send
tt-ext-system.delivery-method
t-delete-pck-on
tg-cert-sign
WITH FRAME Dialog-Frame.
ENABLE
b-exit when p-mode <> 'ПРОСМОТР':U
b-quit
b-help
tt-ext-system.esys-name when p-mode <> 'ПРОСМОТР':U
tt-ext-system.esys-des  when p-mode <> 'ПРОСМОТР':U
tt-ext-system.esys-have-export  when p-mode <> 'ПРОСМОТР':U
tt-ext-system.esys-have-import  when p-mode <> 'ПРОСМОТР':U
tt-ext-system.delivery-method when p-mode <> 'ПРОСМОТР':U
tt-ext-system.esys-type when p-mode <> 'ПРОСМОТР':U
b-links when p-mode <> 'ДОБАВЛЕНИЕ':U
t-delete-pck-on when p-mode <> 'ПРОСМОТР':U
t-exp-conf-wait
t-imp-conf-send
tg-cert-sign when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit in frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
else do:
  run manage-export in this-procedure ( input tt-ext-system.esys-have-export).
  run manage-import in this-procedure ( input tt-ext-system.esys-have-import).
  run manage-exp-conf-wait in this-procedure ( input tt-ext-system.exp-conf-wait).
  run manage-t-delete-pck-on in this-procedure ( input t-delete-pck-on).
end.
run proc-value-change-method in this-procedure (input tt-ext-system.delivery-method) no-error.
run proc-value-changed-cert-sign in this-procedure (input tg-cert-sign) no-error .
END PROCEDURE.
PROCEDURE proc-b-link :
define input parameter p-link-option as character no-undo.
define variable v-rid-list as character no-undo.
define variable v-resource-id as character no-undo.
case p-link-option:
   when "thobjs" then do:
        run ref/esysclis.w ( input parparentproc
                            ,input ""
                            ,input "one"
                            ,input locked_ext-system.esys-id
                            ,input-output v-rid-list) no-error.
   end.
   when "edoc-nn" then do:
      run cus/edoc-cli.w ( input parparentproc
                          ,input ""
                          ,input "esys-id"
                          ,input string(locked_ext-system.esys-id)
                          ,input-output v-rid-list) no-error.
   end.
   when "exite-edi" then do:
      run cus/exiteedi.w ( input parparentproc
                          ,input ""
                          ,input "esys-id"
                          ,input string(locked_ext-system.esys-id)
                          ,input-output v-rid-list) no-error.
   end.
   when "locks" then do:
     run gen-key-rec in this-procedure ( input 'ext-system':U
                                        ,input (buffer locked_ext-system:handle)
                                        ,output v-resource-id).
      run gbl/some-lks.w ( input parparentproc
                            ,input '':U
                            ,input "resource-id"
                            ,input v-resource-id
                            ,input "":U
                            ,input-output v-rid-list) no-error.
   end.
end case.
END PROCEDURE.
PROCEDURE proc-b-host :
define variable ref-list as char no-undo.
DEFINE VARIABLE new-host-code AS INTEGE no-undo.
DEFINE BUFFER buf_sysclients FOR ub.clients.
  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input v-cntxt-host-code-obj
                ,output new-host-code
                ,input-output ref-list ) .
  .
if new-host-code = ?
or new-host-code = 0
then do:
   ASSIGN
   f-host-code = ?
   .
END.
ELSE DO:
  find first buf_sysclients where
            buf_sysclients.obj-type = 'орг':U
        and buf_sysclients.obj-code = new-host-code no-lock.
    ASSIGN
    f-host-code = buf_sysclients.obj-code
    .
END.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-rec as recid no-undo .
define variable psw-buf as character no-undo .
define variable v-attr-code as character no-undo .
define buffer buf_ext-system for ub.ext-system.
if p-mode = 'ПРОСМОТР':U then return.
assign
frame Dialog-Frame
tt-ext-system.esys-name
tt-ext-system.esys-des
tt-ext-system.esys-have-export
tt-ext-system.esys-db-num-exp
tt-ext-system.esys-send-news-exp
tt-ext-system.esys-num-days-keep-exp
tt-ext-system.esys-have-import
tt-ext-system.esys-send-news-imp
tt-ext-system.esys-db-num-imp
tt-ext-system.max-p-queue
tt-ext-system.max-p-time
tt-ext-system.esys-max-p-size
t-exp-conf-wait
t-imp-conf-send
tt-ext-system.delivery-method
t-delete-pck-on
tt-ext-system.delete-pck-on = (IF t-delete-pck-on THEN 1 ELSE 0)
tt-ext-system.save-days-pck-num
tt-ext-system.esys-type
tg-cert-sign
.
if tt-ext-system.delivery-method = integer('2':U)
or tt-ext-system.delivery-method = integer('1':U)
or tt-ext-system.delivery-method = integer('5':U)
or tt-ext-system.delivery-method = integer('9':U)
then do:
   assign
   f-ftp-ip
   f-ftp-path
   f-login.
end.
if tt-ext-system.delivery-method = integer('5':U)
or tt-ext-system.delivery-method = integer('9':U)
then do:
   assign
   f-ftp-path-in
   f-ftp-path-out
   .
end.
if tg-cert-sign then assign
  fi-cert-sign-subject
  fi-cert-sign-issuer
  cb-cert-file-ext
  cb-cert-repository
.
else assign
  fi-cert-sign-subject = ""
  fi-cert-sign-issuer  = ""
  cb-cert-file-ext     = ""
  cb-cert-repository   = ?
.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
   v-rec = recid(locked_ext-system).
end.
IF f-password:VISIBLE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    f-password.
    if f-password <> '':U
    then do:
      run ref/per-pswd.w ( output psw-buf ) .
      if f-password <> psw-buf then do:
        message
        "Пароль не подтвержден"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame Dialog-Frame.
        return error.
      end.
   end.
END.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if tt-ext-system.esys-type = integer('10':U)
  then do :
    find first ext-system no-lock where ext-system.esys-type = integer('10':U) no-error .
    if available ext-system
    then do :
      MESSAGE
      "В системе уже есть ВС с типом 'Меркурий'. Код ВС: " string(ext-system.esys-id)
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    end.
  end.
  do v-ii = 1 to num-entries('FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U):
    v-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U) .
    find first tt-ext-system-attr where
            tt-ext-system-attr.esya-attr-code = v-attr-code no-error.
    if not available tt-ext-system-attr then do:
      create tt-ext-system-attr.
      assign
      tt-ext-system-attr.esys-id = 0
      tt-ext-system-attr.db-num = 0
      tt-ext-system-attr.esya-attr-code = v-attr-code
      .
      release tt-ext-system-attr.
    end.
  end.
end.
for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when 'FTP':U       then tt-ext-system-attr.esya-attr-value = f-ftp-ip.
     when 'Login':U    then tt-ext-system-attr.esya-attr-value = f-login.
     when 'Password':U then tt-ext-system-attr.esya-attr-value = f-password.
     when 'Path':U     then tt-ext-system-attr.esya-attr-value = f-ftp-path.
     when 'IN-dir':U  then tt-ext-system-attr.esya-attr-value = f-ftp-path-in.
     when 'OUT-dir':U then tt-ext-system-attr.esya-attr-value = f-ftp-path-out.
     when 'cert-sign':U         then tt-ext-system-attr.esya-attr-value = string(tg-cert-sign).
     when 'cert-sign-subject':U then tt-ext-system-attr.esya-attr-value = fi-cert-sign-subject.
     when 'cert-sign-issuer':U  then tt-ext-system-attr.esya-attr-value = fi-cert-sign-issuer.
     when 'cert-file-ext':U     then tt-ext-system-attr.esya-attr-value = cb-cert-file-ext.
     when 'cert-repository':U   then tt-ext-system-attr.esya-attr-value = string(cb-cert-repository).
  end case.
end.
run bge/extsyss1.p ( input p-mode
                    ,input no
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.
END PROCEDURE.
PROCEDURE proc-save-motp :
define variable v-rec as recid no-undo .
define variable psw-buf as character no-undo .
define buffer buf_ext-system for ub.ext-system.
if p-mode = 'ПРОСМОТР':U then return.
assign
frame motp-frame
tt-ext-system.esys-name
tt-ext-system.esys-type
f-host-code
f-obj
f-server-addres
f-proxy-addres
f-proxy-login
f-proxy-password
t-proxy-ssl
e-mail-list
.
if tt-ext-system.esys-type = 0 then do:
    MESSAGE
    "Задайте тип ВС"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
   v-rec = recid(locked_ext-system).
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  do v-ii = 1 to num-entries('FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U):
    find first tt-ext-system-attr where
            tt-ext-system-attr.esya-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U) no-error.
    if not available tt-ext-system-attr then do:
      create tt-ext-system-attr.
      assign
      tt-ext-system-attr.esys-id = 0
      tt-ext-system-attr.db-num = 0
      tt-ext-system-attr.esya-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U)
      .
      release tt-ext-system-attr.
    end.
  end.
end.
for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when 'host-code':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = string(f-host-code).
     end.
     when 'obj':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-obj .
     end.
     when 'server-addr':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-server-addres.
     end.
     when 'proxy-addr':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-addres.
     end.
     when 'proxy-login':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-login.
     end.
     when 'proxy-pswd':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-password.
     end.
     when 'proxy-ssl':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = string(t-proxy-ssl).
     end.
     when 'mail-list':U then do:
        assign
        tt-ext-system-attr.esya-attr-value = trim(e-mail-list).
     end.
  end case.
end.
run bge/extsyss1.p ( input p-mode
                    ,input no
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.
END PROCEDURE.
PROCEDURE proc-save-diadoc :
   define variable v-rec as recid no-undo .
   define variable psw-buf as character no-undo .
   define buffer buf_ext-system for ub.ext-system.
   if p-mode = 'ПРОСМОТР':U then return.
   assign
   frame diadoc-frame
   tt-ext-system.esys-name
   tt-ext-system.esys-type
   f-diadoc-user
   f-diadoc-pwd
   f-diadoc-addres
   f-diadoc-key
   f-diadoc-lastload
   f-proxy-addres
   f-proxy-login
   f-proxy-password
   f-host-code
   f-obj
   t-diadoc-ssl
   .
   if tt-ext-system.esys-type = 0 then do:
       MESSAGE
       "Задайте тип ВС"
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
   end.
   if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      v-rec = recid(locked_ext-system).
   end.
   if p-mode = 'ДОБАВЛЕНИЕ':U then do:
     do v-ii = 1 to num-entries('FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U):
       find first tt-ext-system-attr where
               tt-ext-system-attr.esya-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U) no-error.
       if not available tt-ext-system-attr then do:
         create tt-ext-system-attr.
         assign
         tt-ext-system-attr.esys-id = 0
         tt-ext-system-attr.db-num = 0
         tt-ext-system-attr.esya-attr-code = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U)
         .
         release tt-ext-system-attr.
       end.
     end.
   end.
   for each tt-ext-system-attr:
     case tt-ext-system-attr.esya-attr-code:
        when 'obj':U then do:
            assign
            tt-ext-system-attr.esya-attr-value = f-obj .
        end.
        when 'host-code':U then do:
           assign
              tt-ext-system-attr.esya-attr-value = string(f-host-code).
        end.
        when 'diadoc-user':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-user.
        end.
        when 'server-addr':U then do:
           assign
           tt-ext-system-attr.esya-attr-value =  f-diadoc-addres.
        end.
        when 'diadoc-pwd':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-pwd.
        end.
        when 'diadoc-key':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-key.
        end.
        when 'diadoc-lastload':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = string(f-diadoc-lastload).
        end.
        when 'diadoc-ssl':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = string(t-diadoc-ssl).
        end.
        when 'proxy-addr':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-addres.
        end.
        when 'proxy-login':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-login.
        end.
        when 'proxy-pswd':U then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-password.
        end.
     end case.
   end.
run bge/extsyss1.p ( input p-mode
                    ,input no
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer('1':U)
                            ELSE integer('0':U))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.
END PROCEDURE.
PROCEDURE proc-value-change-method :
define input parameter p-delivery-method as integer no-undo.
t-delete-pck-on:label in frame Dialog-Frame = "Удал. ф-лы из HEAP" .
hide
f-ftp-ip in frame Dialog-Frame
f-login
f-ftp-path-in
f-ftp-path-out
f-ftp-path
fi-screen-pass
f-password in frame Dialog-Frame.
case p-delivery-method:
   when integer('2':U)
   or
   when integer('1':U)
   then do:
     display
     f-ftp-ip
     f-ftp-path
     f-login
     f-password
     with frame Dialog-Frame.
     if p-mode <> 'ПРОСМОТР':U then do:
        enable
        f-ftp-ip
        f-ftp-path
        f-login
        f-password
        with frame Dialog-Frame.
     END.
   END.
  when integer('5':U)
  or
  when integer('9':U)
  then do:
    display
    f-ftp-ip
    f-ftp-path
    f-ftp-path-in
    f-ftp-path-out
    f-login
    f-password
    with frame Dialog-Frame.
    if p-mode <> 'ПРОСМОТР':U then do:
      enable
      f-ftp-ip
      f-ftp-path
      f-ftp-path-in
      f-ftp-path-out
      f-login
      f-password
      with frame Dialog-Frame.
    end.
  end.
  when integer('10':U)
  then do:
    t-delete-pck-on:label in frame Dialog-Frame = 'Удал. записи с УТМ'.
  end.
  when integer('11':U)
  then do:
      disable
      T-exp-conf-wait
      T-imp-conf-send
      with frame Dialog-Frame.
  end.
  otherwise do:
  end.
 END CASE.
END PROCEDURE.
PROCEDURE proc-value-changed-cert-sign PRIVATE :
define input parameter p-is-sign-checked as logical no-undo .
  if p-is-sign-checked then do :
    display
      fi-cert-sign-subject
      fi-cert-sign-issuer
      cb-cert-file-ext
      cb-cert-repository
    with frame Dialog-Frame .
    if p-mode <> 'ПРОСМОТР':U then do:
        enable
      fi-cert-sign-subject
      fi-cert-sign-issuer
      cb-cert-file-ext
      cb-cert-repository
        with frame Dialog-Frame.
    end .
  end .
  else do :
    hide
      fi-cert-sign-subject in frame Dialog-Frame
      fi-cert-sign-issuer  in frame Dialog-Frame
      cb-cert-file-ext     in frame Dialog-Frame
      cb-cert-repository   in frame Dialog-Frame
    .
  end .
END PROCEDURE.
PROCEDURE proc-value-changed-esys-type :
DEFINE INPUT PARAMETER p-esys-type AS INTEGER NO-UNDO.
define variable v-dm-method as integer   no-undo .
if p-esys-type = integer('11':U)
then do :
  hide frame Dialog-Frame .
  hide frame diadoc-frame .
  run Motp-Enable .
end .
else if p-esys-type = 12
then do :
  hide frame Dialog-Frame .
  hide frame motp-frame .
  run diadoc-Enable .
end .
else do :
  hide frame motp-frame .
  hide frame diadoc-frame .
  run myenable .
  case p-esys-type:
     when integer('3':U) then do:
       v-dm-method = integer('3':U).
    end.
    when integer('5':U) then do:
       v-dm-method = integer('2':U).
    end.
    when integer('6':U)
    or
    when integer('7':U) then do:
      v-dm-method = integer('4':U).
    end.
    when integer('9':U) then do:
      v-dm-method = integer('5':U).
    end.
    otherwise do:
      v-dm-method = integer('0':U).
    end.
  end case.
  assign
  tt-ext-system.delivery-method = v-dm-method.
  display
  tt-ext-system.delivery-method
  with frame Dialog-Frame .
  run proc-value-change-method in this-procedure ( input  v-dm-method).
end .
END PROCEDURE.
