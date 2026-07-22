block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: eflimits.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/eflimits.p $":U .
define variable vss-description as character no-undo init "Изменение данных по топливу для мобильного блока EasyFuel".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE ub.dis-card-property
field rw-option as character
field prop-label as character
field node-label as character
field data-type as character
field range as integer
INDEX attrc is
UNIQUE PRIMARY
prop-label
node-label
dt-code
host-code
obj-type
obj-code
INDEX attrcl is UNIQUE
dt-code
node-code
host-code
obj-type
obj-code
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure init-temp-dcp :
define input parameter p-mode as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-sum-id as character no-undo .
define input parameter p-dt-code as integer no-undo .
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-property-value-character as character no-undo .
define variable v-rw-option as character no-undo .
define variable v-range as integer no-undo .
define variable v-node-code-label as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-entry2 as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_Dis-card-property for ub.dis-card-property.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  For each temp-dis-card-property where
          temp-dis-card-property.d-card = p-d-card
      and (p-dtm-code = 0 or temp-dis-card-property.dtm-code = p-dtm-code)
      and (p-dt-code = 0 or temp-dis-card-property.dt-code = p-dt-code):
    delete temp-dis-card-property.
  end.
  For each buf_dis-card-property no-lock where
          buf_dis-card-property.d-card = p-d-card
      and (p-dtm-code = 0 or buf_dis-card-property.dtm-code = p-dtm-code)
      and (p-dt-code = 0 or buf_dis-card-property.dt-code = p-dt-code)
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_prop-head no-lock where
              buf_prop-head.dtm-code = buf_dis-card-property.dtm-code no-error .
    run discprop-node-code (
                       input buf_dis-card-property.dtm-code
                      ,input buf_dis-card-property.node-code
                      ,output v-data-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                       ).
    create temp-dis-card-property.
    assign
    temp-dis-card-property.d-card     = buf_dis-card-property.d-card
    temp-dis-card-property.dt-code    = buf_dis-card-property.dt-code
    temp-dis-card-property.sum-id     = buf_dis-card-property.sum-id
    temp-dis-card-property.dtm-code   = buf_dis-card-property.dtm-code
    temp-dis-card-property.data-type  = v-data-type
    temp-dis-card-property.range      = v-range
    temp-dis-card-property.node-label = v-label
    temp-dis-card-property.prop-label = (if available buf_prop-head
                                         then buf_prop-head.prop-label
                                         else '':U)
    temp-dis-card-property.property-value-character = buf_dis-card-property.property-value-character
    temp-dis-card-property.property-value-date = buf_dis-card-property.property-value-date
    temp-dis-card-property.property-value-decimal = buf_dis-card-property.property-value-decimal
    temp-dis-card-property.property-value-integer = buf_dis-card-property.property-value-integer
    temp-dis-card-property.rw-option = v-rw-option
    temp-dis-card-property.node-code = buf_dis-card-property.node-code
    temp-dis-card-property.host-code = buf_dis-card-property.host-code
    temp-dis-card-property.obj-type = buf_dis-card-property.obj-type
    temp-dis-card-property.obj-code = buf_dis-card-property.obj-code
    .
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lock-dcp :
define input parameter p-d-card as character no-undo .
define parameter buffer locked_dis-card-property for ub.dis-card-property.
  do
  on error undo, return error
  on stop undo, return error
  on end-key undo, return error
  :
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error no-wait.
      if not available locked_dis-card-property
      and not locked locked_dis-card-property then do:
        create locked_dis-card-property.
        assign
        locked_dis-card-property.host-code = 0
        locked_dis-card-property.obj-type =  '':U
        locked_dis-card-property.obj-code = 0
        locked_dis-card-property.d-card = p-d-card
        locked_dis-card-property.dtm-code = 0
        locked_dis-card-property.dt-code = 0
        locked_dis-card-property.node-code = 0
        .
      end.
      if locked locked_dis-card-property then do:
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = p-d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error .
      end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info8 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info8, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info8, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info8 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info8, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info8 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info8, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info8, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info8, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info8, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info8, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info8 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info8 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info8, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info8 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info8 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, v-tbl-name ).
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
define stream stmxmlout .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-ef no-undo
field d-card as character
field car-reg-number as character label "Госрег. номер"
field car-brand as character  label "Марка трансп. ср-ва"
field ef-format as integer    label "Формат записи на МБ"
field access-key as character
field petrol-code-1 as integer label "Топливо №1"
field petrol-code-2 as integer label "Топливо №2"
field petrol-code-3 as integer label "Топливо №3"
field petrol-code-4 as integer label "Топливо №4"
field init-date-time as character
field petrol-list-1 as character
field petrol-list-2 as character
field issue-code as integer  label "Выдал магазин"
field db-num as integer
field user-id as integer
field issue-date as date     label "Дата Выдачи"
field issue-time as integer
field valid-from as date     label "Действует с"
field valid-date as date     label "Действует по"
field issued-by as character label "Выдал оператор"
field init-operator as character label "Прошивал"
index pi is unique primary
d-card
.
DEFINE TEMP-TABLE temp-ef1 NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER  format ">>>>>>>>9"  label "Код в IBS TH"
FIELD sum-id AS character
FIELD dt-code AS integer
FIELD dtm-code AS integer
FIELD ef-petrol-code AS INTEGER   label "Код топлива EasyFuel"
FIELD common-limit AS DECIMAL label "Общий лимит"
FIELD unlim-common-limit AS logical label "Общий!лимит!неогран"
FIELD month-limit AS DECIMAL label "Месячный лимит"
FIELD unlim-month-limit AS logical label "Месячн!лимит!неогран"
FIELD day-limit AS DECIMAL label "Дневной лимит"
FIELD unlim-day-limit AS logical label "Дневн!лимит!неогран"
FIELD standard-dose AS DECIMAL label "Cтандартная доза"
FIELD petrol-num AS INTEGER  label "№ топлива на МБ"
FIELD common-expense AS DECIMAL label "Общий расход"
FIELD month-expense AS DECIMAL label "Месячный расход"
FIELD day-expense AS DECIMAL label "Дневной расход"
FIELD last-date AS Date label "Дата посл.измен"
FIELD last-time AS integer
field new_ as logical
INDEX pi IS UNIQUE PRIMARY
d-card
dt-code
INDEX ip petrol-code
index iefp ef-petrol-code
.
DEFINE TEMP-TABLE temp-efh NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER
FIELD ef-petrol-code AS INTEGER
field seq as integer
field date_ as date
field time_ as integer
field obj-code as integer
field pump-code as integer
field nozzle-code as integer
field cash-desk as integer
field chk-num as integer
field doc-qnty-pl100 as decimal
INDEX pi IS UNIQUE PRIMARY
d-card
petrol-code
INDEX ip petrol-code
.
DEFINE TEMP-TABLE temp-ef2 NO-UNDO
field d-card as character
FIELD month-limit AS DECIMAL
FIELD day-limit AS DECIMAL
FIELD standard-dose AS DECIMAL
FIELD common-limit AS DECIMAL
FIELD purse-num AS INTEGER
INDEX pi IS UNIQUE PRIMARY
d-card purse-num
.
FUNCTION get-ef-petrol-code RETURNS INTEGER
  ( INPUT p-b-code AS INTEGER ) :
DEFINE VARIABLE v-ef-petrol-code AS INTEGER NO-UNDO.
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_goods NO-LOCK WHERE
        buf_goods.gds-code = p-b-code .
run gen-key-rec in THIS-PROCEDURE ( INPUT 'goods':U
                                  ,INPUT (buffer buf_goods:HANDLE)
                                    ,OUTPUT v-key-rec).
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = 'goods':U
         AND buf_Ext-classif.classif-name = 'exp-easyfuel-talon-gds-code':U
      AND buf_ext-classif.uniq-key-rec = v-key-rec NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   ASSIGN
   v-ef-petrol-code = buf_ext-classif.key#_one.
 END.
 RETURN v-ef-petrol-code.
END FUNCTION.
FUNCTION get-petrol-gds-code RETURNS INTEGER
  ( INPUT p-ef-petrol-code AS INTEGER ) :
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = 'goods':U
         AND buf_Ext-classif.classif-name = 'exp-easyfuel-talon-gds-code':U
      AND buf_ext-classif.key#_one = p-ef-petrol-code NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   run gen-row-keyr in this-procedure (
                                        input  buf_ext-classif.uniq-key-rec
                                       ,input ?
                                       ,input "ub"
                                       ,input ?
                                       ,input no-lock
                                       ,output v-tbl-row
                                       ,output v-tbl-name) no-error.
   if not error-status:error then do:
     find first buf_goods no-lock where
              rowid(buf_goods) = v-tbl-row.
     return buf_goods.gds-code.
   end.
 END.
 RETURN 0.
END FUNCTION.
procedure fill-main-table :
define input parameter p-d-card as character no-undo .
define parameter buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-dis-card-property for temp-dis-card-property.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  for each buf_temp-ef:
    delete buf_temp-ef.
  end.
  create buf_temp-ef.
  buf_temp-ef.ef-format = 1.
  if available buf_dis-card then do:
    buffer-copy buf_dis-card
    except d-card
    to buf_temp-ef
    assign
    buf_temp-ef.d-card = p-d-card
    .
  end.
  else do:
    assign
    buf_temp-ef.d-card = p-d-card.
  end.
 FOR EACH temp-dis-card-property where
       temp-dis-card-property.d-card = p-d-card
    and temp-dis-card-property.dtm-code = 25
    :
   CASE temp-dis-card-property.node-code:
     WHEN 1 THEN DO:
       buf_temp-ef.car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN 2 THEN DO:
        buf_temp-ef.car-brand = temp-dis-card-property.property-value-character.
     END.
     WHEN 3 THEN DO:
       buf_temp-ef.ef-format = temp-dis-card-property.property-value-integer.
       IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
     END.
     WHEN 4 THEN DO:
       buf_temp-ef.access-key = temp-dis-card-property.property-value-character.
     END.
     WHEN 5 THEN DO:
       buf_temp-ef.petrol-code-1 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 6 THEN DO:
       buf_temp-ef.petrol-code-2 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 7 THEN DO:
        buf_temp-ef.petrol-code-3 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 8 THEN DO:
       buf_temp-ef.petrol-code-4 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 11 THEN DO:
        buf_temp-ef.init-date-time = temp-dis-card-property.property-value-character.
     END.
     WHEN 12 THEN DO:
        buf_temp-ef.init-operator = temp-dis-card-property.property-value-character.
     END.
     WHEN 13 THEN DO:
        buf_temp-ef.issued-by = temp-dis-card-property.property-value-character.
        buf_temp-ef.db-num = integer(entry(1, temp-dis-card-property.property-value-character, "-")).
        buf_temp-ef.user-id = integer(entry(2, temp-dis-card-property.property-value-character, "-")).
     END.
   END CASE.
 END.
 RUN fill-tables IN THIS-PROCEDURE ( INPUT buf_temp-ef.ef-format, buffer buf_temp-ef) NO-ERROR.
end.
end procedure.
PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
DEFINE BUFFER bufl_temp-dis-card-property FOR temp-dis-card-property.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
CASE p-ef-format:
  WHEN 1  THEN DO:
    FOR EACH bufl_temp-dis-card-property NO-LOCK WHERE
            bufl_temp-dis-card-property.d-card = buf_temp-ef.d-card
         AND bufl_temp-dis-card-property.dtm-code = 24:
      FIND FIRST temp-ef1 WHERE
                temp-ef1.d-card = buf_temp-ef.d-card
            and temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code NO-ERROR.
      IF NOT AVAILABLE temp-ef1 THEN do:
         CREATE temp-ef1.
         ASSIGN
         temp-ef1.d-card = buf_temp-ef.d-card
         temp-ef1.sum-id = bufl_temp-dis-card-property.sum-id
         temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code
         temp-ef1.dtm-code = bufl_temp-dis-card-property.dtm-code
         .
         v-gds-code = propreft-string-to-petrol( INPUT bufl_temp-dis-card-property.sum-id).
         ASSIGN
         temp-ef1.petrol-code  = v-gds-CODE
         .
         ASSIGN
         temp-ef1.ef-petrol-code = get-ef-petrol-code ( temp-ef1.petrol-code)
          .
         DO v-ii = 1 TO 4:
           IF temp-ef1.petrol-code = buffer buf_temp-ef:buffer-field( substitute("petrol-code-&1", v-ii)):buffer-value THEN DO:
             temp-ef1.petrol-num = v-ii.
           END.
         END.
      END.
      CASE bufl_temp-dis-card-property.node-code:
        WHEN 1 THEN DO:
            ASSIGN
            temp-ef1.month-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-month-limit = (temp-ef1.month-limit = ?)
            .
        END.
        WHEN 2 THEN DO:
            ASSIGN
            temp-ef1.day-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-day-limit = (temp-ef1.day-limit = ?)
            .
        END.
        WHEN 3 THEN DO:
            ASSIGN
            temp-ef1.standard-dose = bufl_temp-dis-card-property.property-value-decimal.
        END.
        WHEN 4 THEN DO:
            ASSIGN
            temp-ef1.common-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-common-limit = (temp-ef1.common-limit = ?)
            .
        END.
      END CASE.
   END.
  END.
  OTHERWISE DO:
     MESSAGE
     substitute("Формат данныx &1 для МБ в настоящий момент не поддерживается", p-ef-format)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
END CASE.
END PROCEDURE.
procedure fill-expenses :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
define variable v-cd-petrol-code as character no-undo .
define buffer buf_cd-trans for ub.cd-trans.
define buffer bufe_cd-trans for ub.cd-trans.
define buffer buf_temp-ef1 for temp-ef1.
do
on error undo, return error
:
  for each buf_temp-ef1 where
        buf_temp-ef1.d-card = buf_temp-ef.d-card:
    find last buf_cd-trans no-lock where
            buf_cd-trans.trans-type  = integer('40':U)
        and buf_cd-trans.charkey_one = buf_temp-ef.d-card
        and buf_cd-trans.charkey_two = v-cd-petrol-code use-index ichkdate
          no-error.
    if available buf_cd-trans then do:
      find first bufe_cd-trans no-lock where
            bufe_cd-trans.trans-type  = integer('41':U)
        and bufe_cd-trans.charkey_one = buf_temp-ef.d-card
        and bufe_cd-trans.charkey_two = v-cd-petrol-code
        and bufe_cd-trans.trans-id-chr = buf_cd-trans.trans-id-chr use-index ichkdate no-error .
      if available bufe_cd-trans then do:
        assign
        buf_temp-ef1.common-expense = buf_cd-trans.deckey_one
        buf_temp-ef1.month-expense = buf_cd-trans.deckey_two
        buf_temp-ef1.day-expense = buf_cd-trans.deckey_three
        buf_temp-ef1.last-date = buf_cd-trans.chk-date
        .
      end.
      else do:
        assign
        buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
        .
      end.
    end.
    else do:
      assign
      buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table vidtemp-ef no-undo
field d-card as character
field car-reg-number as character label "Госрег. номер"
field car-brand as character  label "Марка трансп. ср-ва"
field ef-format as integer    label "Формат записи на МБ"
field access-key as character
field petrol-code-1 as integer label "Топливо №1"
field petrol-code-2 as integer label "Топливо №2"
field petrol-code-3 as integer label "Топливо №3"
field petrol-code-4 as integer label "Топливо №4"
field init-date-time as character
field petrol-list-1 as character
field petrol-list-2 as character
field issue-code as integer  label "Выдал магазин"
field db-num as integer
field user-id as integer
field issue-date as date     label "Дата Выдачи"
field issue-time as integer
field valid-from as date     label "Действует с"
field valid-date as date     label "Действует по"
field issued-by as character label "Выдал оператор"
field init-operator as character label "Прошивал"
index pi is unique primary
d-card
.
DEFINE TEMP-TABLE vidtemp-ef1 NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER  format ">>>>>>>>9"  label "Код в IBS TH"
FIELD sum-id AS character
FIELD dt-code AS integer
FIELD dtm-code AS integer
FIELD ef-petrol-code AS INTEGER   label "Код топлива EasyFuel"
FIELD common-limit AS DECIMAL label "Общий лимит"
FIELD unlim-common-limit AS logical label "Общий!лимит!неогран"
FIELD month-limit AS DECIMAL label "Месячный лимит"
FIELD unlim-month-limit AS logical label "Месячн!лимит!неогран"
FIELD day-limit AS DECIMAL label "Дневной лимит"
FIELD unlim-day-limit AS logical label "Дневн!лимит!неогран"
FIELD standard-dose AS DECIMAL label "Cтандартная доза"
FIELD petrol-num AS INTEGER  label "№ топлива на МБ"
FIELD common-expense AS DECIMAL label "Общий расход"
FIELD month-expense AS DECIMAL label "Месячный расход"
FIELD day-expense AS DECIMAL label "Дневной расход"
FIELD last-date AS Date label "Дата посл.измен"
FIELD last-time AS integer
field new_ as logical
INDEX pi IS UNIQUE PRIMARY
d-card
dt-code
INDEX ip petrol-code
index iefp ef-petrol-code
.
DEFINE TEMP-TABLE vidtemp-efh NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER
FIELD ef-petrol-code AS INTEGER
field seq as integer
field date_ as date
field time_ as integer
field obj-code as integer
field pump-code as integer
field nozzle-code as integer
field cash-desk as integer
field chk-num as integer
field doc-qnty-pl100 as decimal
INDEX pi IS UNIQUE PRIMARY
d-card
petrol-code
INDEX ip petrol-code
.
DEFINE TEMP-TABLE vidtemp-ef2 NO-UNDO
field d-card as character
FIELD month-limit AS DECIMAL
FIELD day-limit AS DECIMAL
FIELD standard-dose AS DECIMAL
FIELD common-limit AS DECIMAL
FIELD purse-num AS INTEGER
INDEX pi IS UNIQUE PRIMARY
d-card purse-num
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE DEC-TO-HEX :
DEFINE INPUT PARAMETER  pp-base10       AS INTEGER              NO-UNDO.
DEFINE OUTPUT PARAMETER pp-hex          AS CHARACTER            NO-UNDO.
DEFINE OUTPUT PARAMETER pp-result       AS INTEGER  INITIAL 99  NO-UNDO.
DEFINE VARIABLE         pv-base10       AS INTEGER              NO-UNDO.
DEFINE VARIABLE         pv-hex          AS CHARACTER            NO-UNDO.
REPEAT:
  IF RETRY THEN DO:
    pp-result = 660.
    RETURN.
  END.
  pv-base10 = pp-base10 MODULO 16.
  IF pv-base10 < 10 THEN DO:
    pv-hex = STRING(pv-base10) + pv-hex.
  END.
  ELSE DO:
    pv-hex = CHR(ASC("A") + pv-base10 - 10) + pv-hex.
  END.
  IF pp-base10 < 16 THEN DO:
    LEAVE.
  END.
  pp-base10 = (pp-base10 - pv-base10) / 16.
END.
pp-hex = pv-hex.
pp-result = 0.
END PROCEDURE.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-nodes no-undo
field nhandle as handle
field nname as character
index pi is unique primary
nhandle
.
procedure set-cmd-file :
define input parameter p-cmd-name as character no-undo .
define input parameter p-nid as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-xml-file as character no-undo .
do
on error undo, return error
:
  define variable hdoc as handle no-undo .
  define variable hroot as handle no-undo .
  define variable hrow as handle no-undo .
  define variable hfield as handle no-undo .
  define variable htext as handle no-undo .
  define variable v-ii as integer no-undo .
  create x-document hdoc.
  create x-noderef hroot.
  create x-noderef hrow.
  create x-noderef hfield.
  create x-noderef htext.
  hdoc:create-node(hroot, "InitVid", "element").
  hdoc:encoding = "WINDOWS-1251".
  hdoc:append-child(hroot).
  hroot:set-attribute("mode", "command").
  hroot:set-attribute("vid",  substitute("&1", p-d-card)).
  if p-nid <> "":U then do:
    hroot:set-attribute("nid", p-nid).
  end.
  hroot:set-attribute("token", substitute("&1&2", v-cntxt-obj-type, v-cntxt-obj-code)).
  if p-cmd-name <> "" then do:
    do v-ii = 1 to num-entries(p-cmd-name):
      run value( substitute("command_set_&1", entry(v-ii, p-cmd-name))) in this-procedure ( input p-d-card
                                                                        ,input hdoc
                                                                        ,input hroot).
    end.
  end.
  hdoc:save("file", p-xml-file).
  for each temp-nodes:
    delete object temp-nodes.nhandle.
    delete temp-nodes.
  end.
  delete object hdoc.
  delete object hroot.
  delete object hrow.
  delete object hfield.
  delete object htext.
end.
end procedure.
procedure get-cmd-file :
define input parameter p-cmd-name as character no-undo .
define input parameter p-xml-file as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-option as character no-undo .
define output parameter p-error-code as character no-undo.
define variable hdoc as handle no-undo .
define variable hroot as handle no-undo .
define variable htext as handle no-undo .
define variable hattr as handle no-undo .
define variable herror as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-mode as character no-undo .
define variable v-d-card as character no-undo .
define variable v-obj-type-code as character no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-mess2 as character no-undo .
define variable glog as logical no-undo .
do
on error undo, return error
:
  create x-document hdoc.
  create x-noderef hroot.
  create x-noderef htext.
  create x-noderef hattr.
  create x-noderef herror.
  assign
  glog = hdoc:load("file", p-xml-file, false) no-error.
  if error-status:error
  or not glog
  or  error-status:get-message(1) <> ""
  then do:
    message
    "Ошибка при чтении файла XML-ответа от программы инициализации"
    error-status:get-message(1) skip
    return-value view-as alert-box .
    undo, return error .
  end.
  else if p-cmd-name <> ''
  and p-cmd-name <> "readid" then do:
  end.
  hdoc:get-document-element(hroot).
  if hroot:get-attribute-node(hattr, "mode") then do:
    v-mode = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "vid") then do:
    v-d-card = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "token") then do:
    v-obj-type-code = hattr:node-value.
  end.
  if hroot:get-attribute-node(hattr, "error") then do:
    assign
    p-error-code = hattr:node-value no-error.
    repeat v-ii = 1 to hroot:num-children:
      hroot:get-child(htext,v-ii).
      if htext:subtype = "text"
      then do:
        v-error-mess = trim(htext:node-value).
        leave.
      end.
    end.
  end.
  if v-mode <> "result"
  then do:
    undo, return error substitute("Ответ программы инициализации МБ имеет неверный формат: &1", v-mode).
  end.
  if v-d-card <> p-d-card
  then do:
    for each temp-nodes:
      delete object temp-nodes.nhandle.
      delete temp-nodes.
    end.
    delete object hdoc.
    delete object hroot.
    delete object hattr.
    delete object htext.
    delete object herror.
    undo, return error substitute("Ответ программы инициализации МБ прислал данные для МБ с ДРУГИМ идентификаторовм &1", v-d-card).
  end.
  if v-obj-type-code <> substitute("&1&2", v-cntxt-obj-type, v-cntxt-obj-code) then do:
    for each temp-nodes:
      delete object temp-nodes.nhandle.
      delete temp-nodes.
    end.
    delete object hdoc.
    delete object hroot.
    delete object hattr.
    delete object htext.
    delete object herror.
    undo, return error substitute("Ответ программы инициализации МБ имеет неверного адресата: &1", v-obj-type-code).
  end.
  repeat v-ii = 1 to hroot:num-children:
    hroot:get-child(htext, v-ii).
    case htext:subtype:
      when "ELEMENT" then do:
        if index(p-cmd-name, htext:name) > 0 then do:
          run value( substitute("command_get_&1", htext:name)) in this-procedure ( input p-d-card
                                                                            ,input hdoc
                                                                            ,input htext) .
          if return-value <> "" then do:
            v-error-mess2 = return-value.
          end.
        end.
      end.
    end case.
  end.
  for each temp-nodes:
    delete object temp-nodes.nhandle.
    delete temp-nodes.
  end.
  delete object hdoc.
  delete object hroot.
  delete object hattr.
  delete object htext.
  delete object herror.
  if p-option = "no-error" then do:
    return substitute("Ошибка при чтении ответа на команду(-ы) &1&2&3"
                         , v-error-mess
                         , chr(10)
                        , v-error-mess2).
  end.
  if v-error-mess <> ''
  or v-error-mess2 <> ''
  then do:
    return error substitute("Ошибка при чтении ответа на команду(-ы) &1&2&3"
                         , v-error-mess
                         , chr(10)
                        , v-error-mess2).
  end.
end.
end procedure.
procedure command_set_readid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadID".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadID", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.
end procedure.
procedure command_get_readid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-hdoc as handle.
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if p-hnode:get-attribute-node(hattr, "vrn") then do:
      assign
      buf2_temp-ef.car-reg-number = hattr:node-value no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "issuer") then do:
      assign
      buf2_temp-ef.issue-code = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "db") then do:
      assign
      buf2_temp-ef.db = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "oper") then do:
      assign
      buf2_temp-ef.user-id = integer(hattr:node-value)  no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "date") then do:
      assign
      buf2_temp-ef.issue-date = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "time") then do:
      assign
      buf2_temp-ef.issue-time = integer(entry(1, hattr:node-value, ":")) * 3600 + integer(entry(1, hattr:node-value, ":")) * 60 + integer(entry(1, hattr:node-value, ":"))
      no-error
      .
    end.
    if P-hnode:get-attribute-node(hattr, "begin") then do:
      assign
      buf2_temp-ef.valid-from = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "end") then do:
      assign
      buf2_temp-ef.valid-date = date(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.
end procedure.
procedure command_set_writeid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where
                buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "WriteID".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteID", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
      buf_temp-nodes.nhandle:set-attribute("vrn", buf_temp-ef.car-reg-number).
      buf_temp-nodes.nhandle:set-attribute("issuer", string(buf_temp-ef.issue-code)).
      buf_temp-nodes.nhandle:set-attribute("db", string(buf_temp-ef.db-num)).
      buf_temp-nodes.nhandle:set-attribute("oper", string(buf_temp-ef.user-id)).
      buf_temp-nodes.nhandle:set-attribute("date", (if buf_temp-ef.issue-date = ?
                                                    then chr(63)
                                                    else string(buf_temp-ef.issue-date, "99.99.9999"))).
      buf_temp-nodes.nhandle:set-attribute("time", string(buf_temp-ef.issue-time, "hh:mm:ss") ).
      buf_temp-nodes.nhandle:set-attribute("begin", (if buf_temp-ef.valid-from = ?
                                                    then chr(63)
                                                    else string(buf_temp-ef.valid-from, "99.99.9999"))).
      buf_temp-nodes.nhandle:set-attribute("end",  (if buf_temp-ef.valid-date = ?
                                                   then chr(63)
                                                   else string(buf_temp-ef.valid-date + 1, "99.99.9999"))).
  end.
end procedure.
procedure command_get_writeid :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.
end procedure.
procedure command_set_readbrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadBrand".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadBrand", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.
end procedure.
procedure command_get_readbrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-hdoc as handle.
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "brand") then do:
      assign
      buf2_temp-ef.car-brand = hattr:node-value  no-error.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.
end procedure.
procedure command_set_writebrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where
                buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "WriteBrand".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteBrand", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
      buf_temp-nodes.nhandle:set-attribute("brand", buf_temp-ef.car-brand).
  end.
end procedure.
procedure command_get_writebrand :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.
end procedure.
procedure command_set_writelimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteLimit".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteLimit", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 4:
    find first buf_temp-ef1 where
              buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.petrol-num = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "Limit", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-ef1 then do:
      buf_temp-nodes.nhandle:set-attribute("product", string(buf_temp-ef1.ef-petrol-code)).
      buf_temp-nodes.nhandle:set-attribute("total", (if buf_temp-ef1.unlim-common-limit
                                                     then "unlimited"
                                                     else string(buf_temp-ef1.common-limit))).
      buf_temp-nodes.nhandle:set-attribute("month", (if buf_temp-ef1.unlim-month-limit
                                                     then "unlimited"
                                                     else string(buf_temp-ef1.month-limit))).
      buf_temp-nodes.nhandle:set-attribute("day", (if buf_temp-ef1.unlim-day-limit
                                                   then "unlimied"
                                                   else string(buf_temp-ef1.day-limit))).
      buf_temp-nodes.nhandle:set-attribute("doze", string(buf_temp-ef1.standard-dose)).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("product", string(0)).
      buf_temp-nodes.nhandle:set-attribute("total", string(0)).
      buf_temp-nodes.nhandle:set-attribute("month", string(0)).
      buf_temp-nodes.nhandle:set-attribute("day", string(0)).
      buf_temp-nodes.nhandle:set-attribute("doze", string(0)).
    end.
  end.
end.
end procedure.
procedure command_get_writelimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
  do
  on error undo, return error
  :
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.
end procedure.
procedure command_set_readlimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadLimit".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadLimit", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.
end procedure.
procedure command_get_readlimit :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle no-undo.
define variable htext as handle no-undo .
define variable v-hdoc as handle no-undo .
define variable helem as handle no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define variable v-petrol-num as integer no-undo init ?.
define variable v-ef-petrol-code as integer no-undo .
define variable v-total as decimal no-undo .
define variable v-total-chr as character no-undo .
define variable v-month as decimal no-undo .
define variable v-month-chr as character no-undo .
define variable v-day as decimal no-undo .
define variable v-day-chr as character no-undo .
define variable v-doze as decimal no-undo .
define variable v-gds-code as integer no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
define buffer buf2_temp-ef1 for vidtemp-ef1 .
define buffer buf_prop-ref for ub.prop-ref.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    create x-noderef htext.
    do v-ii = 1 to p-hnode:num-children:
      P-hnode:get-child(htext, v-ii).
      if htext:subtype = "element"
      and htext:name = "Limit" then do:
        assign
        v-ef-petrol-code = ?
        v-total = ?
        v-month = ?
        v-day = ?
        v-doze = ?
        v-gds-code = ?
        .
        if htext:get-attribute-node(hattr, "n") then do:
          v-petrol-num = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "product") then do:
          v-ef-petrol-code = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "total") then do:
          v-total-chr = hattr:node-value.
          if v-total-chr = "unlimited" then do:
            v-total = ?.
          end.
          else do:
            v-total = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "month") then do:
          v-month-chr = hattr:node-value.
          if v-month-chr = "unlimited" then do:
            v-month = ?.
          end.
          else do:
            v-month = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "day") then do:
          v-day-chr = hattr:node-value.
          if v-day-chr = "unlimited" then do:
            v-day = ?.
          end.
          else do:
            v-day = decimal(hattr:node-value) no-error.
          end.
        end.
        if htext:get-attribute-node(hattr, "doze") then do:
          v-doze = decimal(hattr:node-value) no-error.
        end.
        if v-petrol-num <> ?
        and v-petrol-num <=4
        and v-petrol-num > 0
        then do:
           v-gds-code =  get-petrol-gds-code (v-ef-petrol-code) no-error.
           assign
           buffer buf2_temp-ef:handle:buffer-field( substitute( "petrol-code-&1", v-petrol-num)):buffer-value = v-gds-code.
           if v-ef-petrol-code > 0 then do:
            find first buf2_temp-ef1 where
                        buf2_temp-ef1.d-card = p-d-card
                  and buf2_temp-ef1.ef-petrol-code = v-ef-petrol-code no-error.
            if not available buf2_temp-ef1 then do:
              find first buf_prop-ref no-lock where
                        buf_prop-ref.dtm-code = 24
                    and buf_prop-ref.sum-id = propreft-petrol-to-String(v-gds-code) no-error.
              create buf2_temp-ef1.
              assign
              buf2_temp-ef1.d-card = p-d-card
              buf2_temp-ef1.petrol-code = (if v-gds-code = ? then - v-ef-petrol-code else v-gds-code)
              buf2_temp-ef1.sum-id   = (if available buf_prop-ref then buf_prop-ref.sum-id else "")
              buf2_temp-ef1.dt-code  = (if available buf_prop-ref then buf_prop-ref.dt-code else  - v-gds-code)
              buf2_temp-ef1.dtm-code  = 24
              buf2_temp-ef1.ef-petrol-code  = v-ef-petrol-code
              .
            end.
            assign
            buf2_temp-ef1.common-limit  = v-total
            buf2_temp-ef1.month-limit  = v-month
            buf2_temp-ef1.day-limit  = v-day
            buf2_temp-ef1.standard-dose = v-doze
            buf2_temp-ef1.petrol-num  = v-petrol-num
            .
          end.
        end.
      end.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.
end procedure.
procedure command_set_writecons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteCons".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteCons", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 4:
    find first buf_temp-ef1 where
              buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.petrol-num = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "Consumption", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-ef1 then do:
      buf_temp-nodes.nhandle:set-attribute("total", string(buf_temp-ef1.common-expense)).
      buf_temp-nodes.nhandle:set-attribute("month", string(buf_temp-ef1.month-expense)).
      buf_temp-nodes.nhandle:set-attribute("day", string(buf_temp-ef1.day-expense)).
      buf_temp-nodes.nhandle:set-attribute("date", string((if buf_temp-ef1.last-date = ?
                                                          then buf_temp-ef.valid-from
                                                          else buf_temp-ef1.last-date), "99.99.9999")).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("total", string(0)).
      buf_temp-nodes.nhandle:set-attribute("month", string(0)).
      buf_temp-nodes.nhandle:set-attribute("day", string(0)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-ef.valid-from, "99.99.9999")).
    end.
  end.
end.
end procedure.
procedure command_get_writecons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.
end procedure.
procedure command_set_readcons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-ef for temp-ef.
  do
  on error undo, return error
  :
      find first buf_temp-ef where buf_temp-ef.d-card = p-d-card.
      create buf_temp-nodes.
      create x-noderef buf_temp-nodes.nhandle.
      assign
      buf_temp-nodes.nname = "ReadCons".
      p-hdoc:create-node(buf_temp-nodes.nhandle, "ReadCons", "ELEMENT").
      p-hroot:append-child(buf_temp-nodes.nhandle).
      buf_temp-nodes.nhandle:set-attribute("token",  p-d-card).
      buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  end.
end procedure.
procedure command_get_readcons :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle no-undo.
define variable htext as handle no-undo .
define variable v-hdoc as handle no-undo .
define variable helem as handle no-undo .
define variable v-error-mess as character no-undo .
define variable v-error-code as character no-undo .
define variable v-petrol-num as integer no-undo init ?.
define variable v-total as decimal no-undo .
define variable v-month as decimal no-undo .
define variable v-day as decimal no-undo .
define variable v-last-date as date no-undo .
define variable v-last-time as integer no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef .
define buffer buf2_temp-ef1 for vidtemp-ef1 .
define buffer buf_prop-ref for ub.prop-ref.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "format") then do:
      assign
      buf2_temp-ef.ef-format = integer(hattr:node-value) no-error.
    end.
    create x-noderef htext.
    do v-ii = 1 to p-hnode:num-children:
      P-hnode:get-child(htext, v-ii).
      if htext:subtype = "element"
      and htext:name = "Consumption" then do:
        assign
        v-total = ?
        v-month = ?
        v-day = ?
        v-last-date = ?
        .
        if htext:get-attribute-node(hattr, "n") then do:
          v-petrol-num = integer(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "total") then do:
          v-total = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "month") then do:
          v-month = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "day") then do:
          v-day = decimal(hattr:node-value) no-error.
        end.
        if htext:get-attribute-node(hattr, "date") then do:
          assign
          v-last-date = date(hattr:node-value) no-error.
        end.
        if v-petrol-num <> ?
        and v-petrol-num <=4
        and v-petrol-num > 0
        then do:
          find first buf2_temp-ef1 where
                      buf2_temp-ef1.d-card = p-d-card
                and buf2_temp-ef1.petrol-num = v-petrol-num no-error.
          if available buf2_temp-ef1 then do:
            assign
            buf2_temp-ef1.common-expense  = v-total
            buf2_temp-ef1.month-expense  = v-month
            buf2_temp-ef1.day-expense  = v-day
            buf2_temp-ef1.last-date  = v-last-date
            .
          end.
        end.
      end.
    end.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      assign
      v-error-code = hattr:node-value no-error.
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    if v-error-code = "99"
    or v-error-code = ""
    or v-error-code = ?
    then return "".
    return v-error-mess.
  end.
end procedure.
procedure command_set_writehistory :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hroot  as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-wl-handle as handle no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf_temp-efh for temp-efh.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  find first buf_temp-ef where
            buf_temp-ef.d-card = p-d-card.
  create buf_temp-nodes.
  create x-noderef buf_temp-nodes.nhandle.
  assign
  buf_temp-nodes.nname = "WriteHistory".
  p-hdoc:create-node(buf_temp-nodes.nhandle, "WriteHistory", "ELEMENT").
  p-hroot:append-child(buf_temp-nodes.nhandle).
  buf_temp-nodes.nhandle:set-attribute("token", p-d-card).
  buf_temp-nodes.nhandle:set-attribute("format", string(buf_temp-ef.ef-format)).
  v-wl-handle = buf_temp-nodes.nhandle.
  do v-ii = 1 to 6:
    find first buf_temp-efh where
              buf_temp-efh.d-card = p-d-card
            and buf_temp-efh.seq = v-ii no-error.
    create buf_temp-nodes.
    create x-noderef buf_temp-nodes.nhandle.
    p-hdoc:create-node(buf_temp-nodes.nhandle, "History", "ELEMENT").
    v-wl-handle:append-child(buf_temp-nodes.nhandle).
    buf_temp-nodes.nhandle:set-attribute("n", string(v-ii)).
    if available buf_temp-efh then do:
      buf_temp-nodes.nhandle:set-attribute("seq", string(buf_temp-efh.seq)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-efh.date_, "99.99.9999")).
      buf_temp-nodes.nhandle:set-attribute("time", string(buf_temp-efh.time_, "hh:mm:ss")).
      buf_temp-nodes.nhandle:set-attribute("azs", string(buf_temp-efh.obj-code)).
      buf_temp-nodes.nhandle:set-attribute("product", string(buf_temp-efh.ef-petrol-code)).
      buf_temp-nodes.nhandle:set-attribute("fpoint", string(buf_temp-efh.pump-code)).
      buf_temp-nodes.nhandle:set-attribute("nozzle", string(buf_temp-efh.nozzle-code)).
      buf_temp-nodes.nhandle:set-attribute("volume", string(buf_temp-efh.doc-qnty-pl100)).
      buf_temp-nodes.nhandle:set-attribute("cassa", string(buf_temp-efh.cash-desk)).
      buf_temp-nodes.nhandle:set-attribute("doc", string(buf_temp-efh.chk-num)).
    end.
    else do:
      buf_temp-nodes.nhandle:set-attribute("seq", string(0)).
      buf_temp-nodes.nhandle:set-attribute("date", string(buf_temp-ef.valid-from, "99.99.9999")).
      buf_temp-nodes.nhandle:set-attribute("time", string(0, "hh:mm:ss")).
      buf_temp-nodes.nhandle:set-attribute("azs", string(0)).
      buf_temp-nodes.nhandle:set-attribute("product", string(0)).
      buf_temp-nodes.nhandle:set-attribute("fpoint", string(1)).
      buf_temp-nodes.nhandle:set-attribute("nozzle", string(1)).
      buf_temp-nodes.nhandle:set-attribute("volume", string(0)).
      buf_temp-nodes.nhandle:set-attribute("cassa", string(0)).
      buf_temp-nodes.nhandle:set-attribute("doc", string(0)).
    end.
  end.
end.
end procedure.
procedure command_get_writehistory :
define input parameter p-d-card as character no-undo .
define input parameter p-hdoc   as handle no-undo .
define input parameter p-hnode  as handle no-undo .
define variable v-ii as integer no-undo .
define variable hattr as handle.
define variable htext as handle.
define variable v-error-mess as character no-undo .
define buffer buf_temp-nodes for temp-nodes.
define buffer buf2_temp-ef for vidtemp-ef.
  do
  on error undo, return error
  :
    find first buf2_temp-ef .
    create x-noderef hattr.
    if P-hnode:get-attribute-node(hattr, "error") then do:
      create x-noderef htext.
      repeat v-ii = 1 to P-hnode:num-children:
        P-hnode:get-child(htext, v-ii).
        if htext:subtype = "text" then do:
          v-error-mess = htext:node-value.
          leave.
        end.
      end.
    end.
    delete object hattr.
    delete object htext.
    return v-error-mess.
  end.
end procedure.
procedure prepare-file-names :
define input-output parameter p-out-file as character no-undo .
define input-output parameter p-in-file as character no-undo .
define variable v-xml-file-base as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-xml-path as character no-undo .
do
on error undo, return error
:
  os-delete value(p-out-file).
  os-delete value(p-in-file).
  assign
  v-xml-file-base = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
  p-out-file = substitute("&1c.xml"
                          ,v-xml-file-base
                          )
  p-in-file = substitute("&1r.xml"
                          ,v-xml-file-base
                          )
  .
end.
end procedure.
procedure prepare-cmd-line :
define input parameter p-out-file as character no-undo .
define input parameter p-in-file as character no-undo .
define output parameter p-cmd-line as character no-undo .
define variable v-xml-file-base as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-xml-path as character no-undo .
define variable v-python-path as character no-undo .
define variable v-com-port as character no-undo .
define variable v-controller-no as character no-undo .
define variable glog as logical no-undo .
do
on error undo, return error
:
  run gbl/filename.p  (
                   input p-out-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error  .
  if error-status:error then do:
    undo, return error return-value .
  end.
  assign
  v-xml-path  = v-path.
  run gbl/filename.p  (
                   input "exe/vid/vid.pyc"
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  )  .
  run verify-ini-entry in this-procedure (
                                            INPUT  'python-path'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует путь к подкаталогу установки PYTHON")
                                          ,INPUT yes
                                          ,output v-python-path) no-error .
  if error-status:error or v-python-path = ? then return error return-value .
  RUN verify-file in this-procedure
                                    ( v-python-path
                                    , substitute("Не найден каталог &1 параметр python-path, секция [easyfuel] ini-файла", v-python-path)
                                    , yes
                                    ,output glog) no-error.
  if error-status:error or not glog then return error return-value .
  run verify-ini-entry in this-procedure (
                                            INPUT  'com-port'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует настройка COM-порта для устройтва персонализации МБ")
                                          ,INPUT yes
                                          ,output v-com-port) no-error .
  if error-status:error or v-com-port = ? then do:
    v-com-port = "COM1".
  end.
  run verify-ini-entry in this-procedure (
                                            INPUT  'controller-no'
                                          ,INPUT  'easyfuel'
                                          ,INPUT substitute("в ini-файле отсутствует настройка номера контролера для устройтва персонализации МБ")
                                          ,INPUT yes
                                          ,output v-controller-no) no-error .
  if error-status:error or v-controller-no = ? then do:
    v-controller-no = "1".
  end.
  p-cmd-line = substitute("&7\python.exe &6 &1 &2 &3 &4 &5"
                          ,v-com-port
                          ,v-controller-no
                          ,v-xml-path + chr(47) + p-out-file
                          ,v-xml-path + chr(47) + p-in-file
                          ,""
                          ,v-full-path
                          ,prepare-path(v-python-path)
                                                    ).
end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-labels no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
procedure tempchgs-create-lable-record :
define input parameter p-t_name as character no-undo .
define input parameter p-f_name as character no-undo .
define input parameter p-l_name as character no-undo .
define input parameter p-f_update as logical no-undo .
define input parameter p-f_parent as character no-undo .
define input parameter p-f_visible as logical no-undo .
define buffer buf_temp-labels for temp-labels.
  do
  on error undo, return error
  :
     find first buf_temp-labels where
              buf_temp-labels.t_name = p-t_name
          and buf_temp-labels.f_name = p-f_name no-error.
     if not available buf_temp-labels then do:
      create buf_temp-labels.
      assign
      buf_temp-labels.t_name = p-t_name
      buf_temp-labels.f_name = p-f_name
      buf_temp-labels.l_name = p-l_name
      .
     end.
     assign
     buf_temp-labels.f_can_update = p-f_update
     buf_temp-labels.f_parent = p-f_parent
     buf_temp-labels.f_visible = p-f_visible
     buf_temp-labels.f_root = (if p-f_parent = '':U then p-f_name else p-f_parent)
     buf_temp-labels.num_ = 0
     .
  end.
end procedure.
define variable v-num as integer no-undo .
DEFINE VARIABLE v-rid-list as character no-undo .
define variable v-setted as logical no-undo .
define variable v-sum-id as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-nid as character no-undo .
define variable glog as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer locked_dis-card-property for ub.dis-card-property.
define buffer buf_temp-ef for temp-ef.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef2 for temp-ef2.
define buffer buf2_temp-ef for vidtemp-ef.
define buffer buf2_temp-ef1 for vidtemp-ef1.
define buffer buf2_temp-ef2 for vidtemp-ef2.
run ref/discards.w (
                  input parparentproc
                ,input "b-sel":U
                ,input 'все':U
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,input ?
                ,output v-rid-list ) no-error.
if not v-rid-list  = "" then do:
  FIND FIRST buf_dis-card no-lock where
              recid(buf_dis-card) = integer(v-rid-list).
  if buf_dis-card.status_ = 'неисп':U
  or buf_dis-card.status_ = 'смкли':U
  then do:
    message
    substitute("Нельзя изменять данные МБ &1&2" +
              "Карта имеет статус &3, &4"
            , buf_dis-card.d-card
            , chr(10)
            , buf_dis-card.status_
            , (if buf_dis-card.status_ = 'неисп':U
              then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
              else "карта будет доступна по окончании процесса смены владельца")
                )
    view-as alert-box error .
    return .
  end.
  do
  on error undo, return error return-value
  on stop undo, return error return-value
  on end-key undo, return error return-value :
    run lock-dcp in this-procedure ( input buf_dis-card.d-card
                                    ,buffer locked_dis-card-property).
  end.
  define buffer buf_Dis-card-property for ub.dis-card-property.
  find first buf_Dis-card-property no-lock where
             buf_dis-card-property.dtm-code = 25
         and buf_dis-card-property.d-card = buf_Dis-card.d-card
         and buf_dis-card-property.host-code = 0
         and buf_dis-card-property.obj-type = ''
         and buf_dis-card-property.obj-code = 0 no-error.
  if not available buf_dis-card-property then do:
    message
    substitute("В системе IBS TH нет идентификационных данных EasyFuel для данной карты-МБ &1", buf_Dis-card.d-card)
    view-as alert-box error .
    undo, return ''.
  end.
  assign
  v-sum-id = buf_dis-card-property.sum-id
  v-dt-code = buf_dis-card-property.dt-code
  .
  for each temp-dis-card-property:
    delete temp-dis-card-property.
  end.
  run init-temp-dcp in this-procedure ( input 'ПРОСМОТР':U + chr(44) + "init"
                                      ,input buf_dis-card.d-card
                                      ,input 25
                                      ,input v-sum-id
                                      ,input v-dt-code).
  run init-temp-dcp in this-procedure ( input 'ПРОСМОТР':U + chr(44) + "init"
                                      ,input buf_dis-card.d-card
                                      ,input 24
                                      ,input ""
                                      ,input 0).
  v-setted = yes.
  if v-setted then do:
    run write-log in p-log-handle ( input 0,  "Ждите..." ).
    for each buf_temp-ef:
      delete buf_temp-ef.
    end.
    for each buf_temp-ef1:
      delete buf_temp-ef1.
    end.
    for each buf_temp-ef2:
      delete buf_temp-ef2.
    end.
    run fill-main-table  in this-procedure ( input buf_Dis-card.d-card, buffer buf_Dis-card).
    define variable v-out-file as character no-undo .
    define variable v-in-file as character no-undo .
    define variable v-cmd-line as character no-undo .
    define variable v-time as integer no-undo init 30.
    define variable v-xml-file-base as character no-undo .
    define variable v-error-code as character no-undo.
    for each buf_temp-ef:
      create buf2_temp-ef.
      buffer-copy buf_temp-ef
      to buf2_temp-ef.
    end.
    for each buf_temp-ef1:
      create buf2_temp-ef1.
      buffer-copy buf_temp-ef1
      to buf2_temp-ef1.
    end.
    for each buf_temp-ef2:
      create buf2_temp-ef2.
      buffer-copy buf_temp-ef2
      to buf2_temp-ef2.
    end.
    define variable v-param-type as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    run adm/shattri.p (
         input "get":U
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  'easyfuel':U
        ,input  'master-key':U
        ,output v-nid
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    delete object v-tth.
    v-time = 0 * 10 + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    run set-cmd-file in this-procedure (
                                        input ""
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).
    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error.
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
      undo, return error "".
    end.
    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Проверка связи..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
      undo, return error "".
    end.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                         input ''
                                        ,input v-in-file
                                        ,input buf_Dis-card.d-card
                                        ,input "no-error"
                                        ,output v-error-code)
      no-error.
     if error-status:error then do:
       run write-log in p-log-handle ( input 0,  "Ошибка" ).
       run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value )).
       undo, return error "".
     end.
    end.
    v-time = 1 * 10 + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    run set-cmd-file in this-procedure (
                                        input "ReadID,ReadLimit"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).
    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
       run write-log in p-log-handle ( input 0,  "Ошибка" ).
       run write-log in p-log-handle ( input 0,  return-value ).
       undo, return error "" .
    end.
    run write-log in p-log-handle ( input 0
                                   , substitute("Обращаюсь к программе связи с МБ...&1" +
                                                "Считывание идентификационных данных...&1" +
                                                "Считывание лимитов по топливам..." , chr(10))).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                         input 'ReadId,ReadLimit'
                                        ,input v-in-file
                                        ,input buf_Dis-card.d-card
                                        ,input ""
                                        ,output v-error-code
                                         ) no-error .
      if error-status:error then do:
        run write-log in p-log-handle ( input 0,  "Ошибка" ).
        run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value )).
        undo, return error "".
      end.
    end.
    find first buf_temp-ef where
              buf_temp-ef.d-card = buf_Dis-card.d-card.
    find first buf2_temp-ef where
              buf2_temp-ef.d-card = buf_Dis-card.d-card.
    define variable v-th as handle no-undo .
    define variable v-th2 as handle no-undo .
    define variable v-jj as integer no-undo .
        run create-table in this-procedure ( input "limits", buffer buf_temp-ef, output v-th) .
    run create-table in this-procedure ( input "limits2", buffer buf_temp-ef, output v-th2) .
    run copy-fields in this-procedure ( buffer buf_temp-ef
                                      ,buffer buf2_temp-ef
                                      ,input v-th
                                      ,input v-th2) .
    define variable v-bh1 as handle no-undo .
    define variable v-bh2 as handle no-undo .
    create buffer v-bh1 for table v-th.
    create buffer v-bh2 for table v-th2.
    do v-jj = 1 to v-th:default-buffer-handle:num-fields:
      if v-th:default-buffer-handle:buffer-field(v-jj):name = "record-num" then next.
      run tempchgs-create-lable-record in this-procedure (
                                                          input v-th:name
                                                        , input v-th:default-buffer-handle:buffer-field(v-jj):name
                                                        , input (if v-th:default-buffer-handle:buffer-field(v-jj):name begins "EF-"
                                                                and not (v-th:default-buffer-handle:buffer-field(v-jj):name begins "EF-f")
                                                                then substitute("&1-&2"
                                                                               ,substring(v-th:default-buffer-handle:buffer-field(v-jj):name, 1, 4)
                                                                               ,v-th:default-buffer-handle:buffer-field(v-jj):label
                                                                               )
                                                                else v-th:default-buffer-handle:buffer-field(v-jj):label)
                                                        , input no
                                                        , input ""
                                                        , input yes
                                                       ).
    end.
    define variable v-ok as logical no-undo .
    run ref/view-chg.w (
                         INPUT parparentproc
                        ,input ?
                        ,input "limits"
                        ,input v-bh1
                        ,input v-bh2
                        ,input 'ПРОСМОТР':U + chr(44) + "view-identical"
                        ,input 0
                        ,input "Разница в данных по топливам"
                        ,input "Данные в IBS TH"
                        ,input "Данные на МБ"
                        ,input ""
                        ,input ("Внимательно просмотрите отличающиеся поля (ЕСЛИ ОНИ ЕСТЬ), прежде чем принять решение об изменении данных")
                        ,output v-ok) no-error.
    delete object v-bh1.
    delete object v-bh2.
    delete object v-th.
    delete object v-th2.
    message
    "Провести изменение?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return.
    run write-log in p-log-handle ( input 0,  "Ждите" ).
    v-time = 3 * 10 + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    buffer-copy buf2_temp-ef
    except car-reg-num car-brand
    to buf_temp-ef.
    run set-cmd-file in this-procedure (
                                        input "WriteLimit"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).
    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
      undo, return error "" .
    end.
    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Запись данных по топливам..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                          input 'WriteLimit'
                                         ,input v-in-file
                                         ,input buf_Dis-card.d-card
                                        ,input ""
                                        ,output v-error-code
                                       ) no-error.
      if error-status:error then do:
        run write-log in p-log-handle ( input 0,  "Ошибка" ).
        run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value )).
        undo, return error "".
      end.
      if search("ef-debug.flg") = ? then do:
        os-delete value(v-out-file).
        os-delete value(v-in-file).
      end.
      DEFINE VARIABLE v-today as date no-undo .
      define variable v-chip-num as integer no-undo .
      define variable v-corr-date as date no-undo .
      define variable v-corr-time as integer no-undo .
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-chip-num = 0
      v-corr-date = ?
      v-corr-time = ?.
      run discprop-write  in this-procedure (
                                              input buf_dis-card.d-card
                                              ,input 0
                                              ,input ''
                                              ,input 0
                                              ,input 25
                                              ,input 11
                                              ,input v-dt-code
                                              ,input v-sum-id
                                              ,input Xml-CD-DateTimetoString( v-today, v-time)
                                              ,input ?
                                              ,input 0
                                              ,input 0
                                              ,input no
                                              ,input ""
                                              ,input ""
                                              ,input-output v-chip-num
                                              ,input-output v-corr-date
                                              ,input-output v-corr-time).
      run discprop-write  in this-procedure (
                                              input buf_dis-card.d-card
                                              ,input 0
                                              ,input ''
                                              ,input 0
                                              ,input 25
                                              ,input 12
                                              ,input v-dt-code
                                              ,input v-sum-id
                                              ,input g#userid
                                              ,input ?
                                              ,input 0
                                              ,input 0
                                              ,input no
                                              ,input ""
                                              ,input ""
                                              ,input-output v-chip-num
                                              ,input-output v-corr-date
                                              ,input-output v-corr-time).
      message
      substitute("МБ с номером &1 перепрошит успешно", buf_Dis-card.d-card)
      view-as alert-box .
    end.
    else do:
    end.
  end.
end.
procedure create-table :
define input parameter p-tbl-name as character no-undo .
define parameter buffer buf_temp-ef for temp-ef.
define output parameter v-th as handle no-undo .
define variable v-jj as integer no-undo .
define variable v-fname as character no-undo .
define variable v-fnamelist as character no-undo .
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf2_temp-ef for vidtemp-ef1.
  do
  on error undo, return error
  :
    create temp-table v-th.
    v-th:add-new-field( "record-num", 'integer':U).
    v-th:add-like-field( "petrol-code-1", buffer buf_temp-ef:handle:buffer-field("petrol-code-1")).
    v-th:add-like-field( "petrol-code-2", buffer buf_temp-ef:handle:buffer-field("petrol-code-2")).
    v-th:add-like-field( "petrol-code-3", buffer buf_temp-ef:handle:buffer-field("petrol-code-3")).
    v-th:add-like-field( "petrol-code-4", buffer buf_temp-ef:handle:buffer-field("petrol-code-4")).
    v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
            for each buf_temp-ef1 :
      do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th:add-like-field( substitute("EF-&1-&2", buf_temp-ef1.ef-petrol-code, v-fname), (buffer buf_temp-ef1:handle:buffer-field(v-fname))).      end.
    end.
    for each buf2_temp-ef1 :
      find first buf_temp-ef1 where
                buf_temp-ef1.ef-petrol-code = buf_temp-ef1.ef-petrol-code no-error.
      if not available buf_temp-ef1 then do:
        do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th:add-like-field( substitute("EF-&1-&2", buf2_temp-ef1.ef-petrol-code, v-fname), (buffer buf2_temp-ef1:handle:buffer-field(v-fname))).      end.
      end.
    end.
    v-th:add-new-index("pi", yes, yes).
    v-th:add-index-field("pi", "record-num").
    v-th:temp-table-prepare(p-tbl-name).
  end.
end procedure.
procedure copy-fields :
define parameter buffer buf_temp-ef for temp-ef.
define parameter buffer buf2_temp-ef for vidtemp-ef.
define input parameter v-th as handle no-undo .
define input parameter v-th2 as handle no-undo .
define variable v-jj as integer no-undo .
define variable v-fname as character no-undo .
define variable v-fnamelist as character no-undo .
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf2_temp-ef1 for vidtemp-ef1.
  do
  on error undo, return error
  :
    v-th:default-buffer-handle:buffer-create.
    v-th:default-buffer-handle::record-num = 1.
        v-fnamelist = "petrol-code-1,petrol-code-2,petrol-code-3,petrol-code-4".
            do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th:default-buffer-handle:buffer-field( substitute("&1&2", "", v-fname)):buffer-value = buffer buf_temp-ef:handle:buffer-field(v-fname):buffer-value.     end.
        v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
    for each buf_temp-ef1 :
      do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th:default-buffer-handle:buffer-field( substitute("&1&2", substitute("EF-&1-", buf_temp-ef1.ef-petrol-code), v-fname)):buffer-value = buffer buf_temp-ef1:handle:buffer-field(v-fname):buffer-value.     end.
    end.
    v-th:default-buffer-handle:buffer-release().
    v-th2:default-buffer-handle:buffer-create.
    v-th2:default-buffer-handle::record-num = 1.
        v-fnamelist = "petrol-code-1,petrol-code-2,petrol-code-3,petrol-code-4".
            do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th2:default-buffer-handle:buffer-field( substitute("&1&2", "", v-fname)):buffer-value = buffer buf2_temp-ef:handle:buffer-field(v-fname):buffer-value.     end.
        v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
    for each buf2_temp-ef1 :
      do v-jj = 1 to num-entries(v-fnamelist):       v-fname = entry(v-jj, v-fnamelist).       v-th2:default-buffer-handle:buffer-field( substitute("&1&2", substitute("EF-&1-", buf2_temp-ef1.ef-petrol-code), v-fname)):buffer-value = buffer buf2_temp-ef1:handle:buffer-field(v-fname):buffer-value.     end.
    end.
    v-th2:default-buffer-handle:buffer-release().
  end.
end procedure.
