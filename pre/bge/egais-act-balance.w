using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode       as character no-undo .
define input parameter egais        as class ActBalance no-undo .
define input parameter v-ext-sys    as integer no-undo .
define input parameter v-fs-rar     as character no-undo .
define input parameter bh-act-header  as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ЕГАИС Акт постановки на баланс".
define variable ii                  as integer no-undo .
define variable jj                  as integer no-undo .
define variable nn                  as integer no-undo .
define variable exts                as integer no-undo .
define variable v-position_         as integer no-undo .
define variable v-date              as character no-undo .
define variable v-rid-list          as character no-undo .
define variable par-alcohol         as character no-undo .
define variable par-egais-name      as character no-undo .
define variable par-type            as character no-undo .
define variable v-attr-value        as character            no-undo .
define variable v-attr-type         as character            no-undo .
define variable err-good            as logical no-undo .
define variable p-ext-rec           as recid no-undo .
define variable v-RegID             as character no-undo .
define variable glog        as logical no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define variable qh-gds-act          as handle no-undo .
define variable bh-gds-act          as handle no-undo .
define variable brh-gds-act         as handle no-undo .
define variable v-gds-uniq-key-rec as character no-undo .
define variable v-part-num    as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id    as int64     no-undo .
define variable v-info        as character no-undo .
define variable v-longchar      as memptr no-undo .
define buffer buf_goods         for ub.goods .
define buffer buf_parts         for ub.parts .
define buffer buf_trn-doc       for ub.trn-doc .
define buffer x_ext-classif     for ub.ext-classif .
define buffer x_ext-classif-attr     for ub.ext-classif-attr .
define buffer buf_clob-bind     for ub.clob-bind .
define buffer buf_clob-data     for ub.clob-data .
define stream str-log .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-A      as character                label "Справка А"               format "X(20)"
    field A-qnty        as decimal                  label "Кол-во в справке"
    field A-bottleDate  as date                     label "Дата розлива"
    field A-ttnNumber   as character                label "№ ТТН справки А"         format "X(15)"
    field A-ttnDate     as date                     label "Дата"
    field A-fixNumber   as character                label "№ фиксации в ЕГАИС"      format "X(20)"
    field A-fixDate     as date                     label "Дата фикс."
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
.
define shared  temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.
define variable sw as handle no-undo .
define variable v-file              as character no-undo initial "ActChargeOn1.xml".
DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.
procedure makeXML_TH :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:ain", "http://fsrar.ru/WEGAIS/ActChargeOn") .
    sw:insert-attribute ("xmlns:ainp", "http://fsrar.ru/WEGAIS/ActChargeOn_v2") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryABInfo") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn") .
                sw:start-element ("ain:Header") .
                    sw:write-data-element ("ain:Number", tt-act-header.num) .
                    sw:write-data-element ("ain:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ain:Note", "Необходимо поставить товарные позиции на баланс") .
                    if egais:VerXSD = "2"
                    then do :
                        if tt-act-header.type_ <> "Продукция полученная до 01.01.2016"
                        then
                          sw:write-data-element ("ainp:TypeChargeOn", tt-act-header.type_) no-error .
                        else
                          sw:write-data-element ("ainp:TypeChargeOn", "Продукция, полученная до 01.01.2016") no-error .
                    end.
                sw:end-element ("ain:Header") .
                sw:start-element ("ain:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ain:Position") .
                        sw:write-data-element ("ain:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ain:Product") .
                            sw:write-data-element ("pref:Type", "АП") .
                            sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                            sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error .
                            sw:write-data-element ("doc-code", tt-gds-act.doc-code) no-error .
                            sw:write-data-element ("part-code", tt-gds-act.part-code) no-error .
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") .
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) .
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = 'goods':U
                                                               and X_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do :
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          v-prod = ''.
                          v-impor = ''.
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if egais:VerXSD = "1"
                          and (v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 6 )
                          then do:
                            message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.
                          if egais:VerXSD = "2"
                          and (v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = "" )
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                          end.
                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if egais:VerXSD = "1"
                          and num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 6
                            then
                          do:
                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.
                          sw:start-element ("pref:Producer") .
                            if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                            if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                            sw:start-element ("oref:address").
                              sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                            sw:end-element ("oref:address").
                          sw:end-element ("pref:Producer") .
                          if egais:VerXSD = "1"
                          and v-impor <> ""
                          and v-impor <> ?
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:
                            sw:start-element ("pref:Importer") .
                              if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).
                              if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).
                              sw:end-element ("oref:address").
                            sw:end-element ("pref:Importer") .
                          end.
                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        sw:end-element ("ain:Product") .
                        sw:write-data-element ("ain:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ain:InformAB") .
                            sw:start-element ("ain:InformABReg") .
                                sw:start-element ("ain:InformA") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ain:InformA") .
                            sw:end-element ("ain:InformABReg") .
                        sw:end-element ("ain:InformAB") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :
                        sw:start-element ("ain:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("ain:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("ain:MarkCodeInfo") .
        end.
                    sw:end-element ("ain:Position") .
    end.
                sw:end-element ("ain:Content") .
            sw:end-element ("ns:ActChargeOn") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXML :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:ain", "http://fsrar.ru/WEGAIS/ActChargeOn") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryABInfo") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn") .
                sw:start-element ("ain:Header") .
                    sw:write-data-element ("ain:Number", tt-act-header.num) .
                    sw:write-data-element ("ain:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ain:Note", "Необходимо поставить товарные позиции на баланс") .
                sw:end-element ("ain:Header") .
                sw:start-element ("ain:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ain:Position") .
                        sw:write-data-element ("ain:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ain:Product") .
                            sw:write-data-element ("pref:Type", "АП") .
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") .
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) .
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = 'goods':U
                                                               and X_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do :
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          v-prod = ''.
                          v-impor = ''.
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 6
                          then do:
                            message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.
                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 6
                            then
                          do:
                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.
                          sw:start-element ("pref:Producer") .
                            if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                            if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                            sw:start-element ("oref:address").
                              sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                            sw:end-element ("oref:address").
                          sw:end-element ("pref:Producer") .
                          if v-impor <> ""
                          and v-impor <> ?
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:
                            sw:start-element ("pref:Importer") .
                              if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).
                              if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).
                              sw:end-element ("oref:address").
                            sw:end-element ("pref:Importer") .
                          end.
                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        sw:end-element ("ain:Product") .
                        sw:write-data-element ("ain:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ain:InformAB") .
                            sw:start-element ("ain:InformABReg") .
                                sw:start-element ("ain:InformA") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ain:InformA") .
                            sw:end-element ("ain:InformABReg") .
                        sw:end-element ("ain:InformAB") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :
                        sw:start-element ("ain:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("ain:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("ain:MarkCodeInfo") .
        end.
                    sw:end-element ("ain:Position") .
    end.
                sw:end-element ("ain:Content") .
            sw:end-element ("ns:ActChargeOn") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXML_v2 :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryF1F2Info") .
    sw:insert-attribute ("xmlns:ainp", "http://fsrar.ru/WEGAIS/ActChargeOn_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn_v2") .
                sw:start-element ("ainp:Header") .
                    sw:write-data-element ("ainp:Number", tt-act-header.num) .
                    sw:write-data-element ("ainp:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ainp:Note", "Необходимо поставить товарные позиции на баланс") .
                    if tt-act-header.type_ <> "Продукция полученная до 01.01.2016"
                    then
                      sw:write-data-element ("ainp:TypeChargeOn", tt-act-header.type_) .
                    else
                      sw:write-data-element ("ainp:TypeChargeOn", "Продукция, полученная до 01.01.2016") .
                    if tt-act-header.type_ = "Пересортица" and v-RegID <> "" and v-RegID <> ? then do :
                      sw:write-data-element ("ainp:ActWriteOff", v-RegID) .
                    end.
                sw:end-element ("ainp:Header") .
                sw:start-element ("ainp:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ainp:Position") .
                        sw:write-data-element ("ainp:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ainp:Product") .
                            sw:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) .
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") .
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) .
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = 'goods':U
                                                               and X_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do :
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          def var v-err as logical no-undo.
                          def var v-err-impor as logical no-undo.
                          v-err = false .
                          v-prod = ''.
                          v-impor = ''.
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = ""
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                            v-err = true .
                          end.
                          if not v-err then do :
                            sw:start-element ("pref:Producer") .
                             sw:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw:end-element ("oref:address").
                             sw:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw:end-element ("pref:Producer") .
                          end.
                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        sw:end-element ("ainp:Product") .
                        sw:write-data-element ("ainp:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ainp:InformF1F2") .
                            sw:start-element ("ainp:InformF1F2Reg") .
                                sw:start-element ("ainp:InformF1") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ainp:InformF1") .
                            sw:end-element ("ainp:InformF1F2Reg") .
                        sw:end-element ("ainp:InformF1F2") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :
                        sw:start-element ("ainp:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("ainp:MarkCodeInfo") .
        end.
                    sw:end-element ("ainp:Position") .
    end.
                sw:end-element ("ainp:Content") .
            sw:end-element ("ns:ActChargeOn_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure parseXML :
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    empty temp-table tt-marks .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search("temp.xml"),FALSE).
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    RUN GetChildren(hRoot, 1).
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
end procedure .
procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "ain:Header" or hNoderef:NAME = "ainp:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "ain:Number"
        OR hNoderef:NAME = "ainp:Number" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "ain:ActDate"
        OR hNoderef:NAME = "ainp:ActDate" THEN
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "ainp:TypeChargeOn" THEN do :
            assign tt-act-header.type_    = hText:node-value no-error .
            if tt-act-header.type_ = "Продукция, полученная до 01.01.2016" then tt-act-header.type_ = "Продукция полученная до 01.01.2016" .
        end.
        IF hNoderef:NAME = "ainp:ActWriteOff" THEN assign v-RegID    = hText:node-value no-error .
        IF hNoderef:NAME = "ain:Position"
        OR hNoderef:NAME = "ainp:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "ain:Identity"
        OR hNoderef:NAME = "ainp:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        if hNoderef:NAME = "gds-code" THEN assign tt-gds-act.gds-code = integer(hText:node-value) no-error .
        if hNoderef:NAME = "gds-name" THEN do :
            assign tt-gds-act.gds-name = hText:node-value no-error .
            if tt-gds-act.gds-name = ? or tt-gds-act.gds-name = ""
            then do :
                find first goods no-lock where goods.gds-code = tt-gds-act.gds-code no-error .
                if available goods then tt-gds-act.gds-name = goods.gds-name no-error .
            end.
        end.
        if hNoderef:NAME = "doc-code" THEN assign tt-gds-act.doc-code = hText:node-value no-error .
        if hNoderef:NAME = "part-code" THEN assign tt-gds-act.part-code = hText:node-value no-error .
        IF hNoderef:NAME = "pref:FullName" THEN assign tt-gds-act.egais-name = hText:node-value no-error .
        IF hNoderef:NAME = "pref:AlcCode" THEN do :
            assign tt-gds-act.alc-code = hText:node-value no-error .
            if tt-gds-act.gds-code = ? or tt-gds-act.gds-code = 0
            then do :
                find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                                   and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                                   AND X_ext-classif.db-num = 0
                                                   and X_ext-classif.key#_two = v-ext-sys
                                                   and X_ext-classif.key#_three = 0
                                                   and X_ext-classif.charkey_one = tt-gds-act.alc-code
                                                   and X_eXt-classif.charkey_two = ""
                                                   and X_eXt-classif.charkey_three = ""
                                                   and X_eXt-classif.nonunique = 0
                                                   no-error.
                if available X_ext-classif then do :
                    find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                    assign
                        tt-gds-act.gds-code = buf_goods.gds-code
                        tt-gds-act.gds-name = buf_goods.gds-name
                    .
                    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                                           no-error .
                    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
                end.
            end.
        end.
        IF hNoderef:NAME = "ain:Quantity"
        OR hNoderef:NAME = "ainp:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "iab:Quantity" THEN assign tt-gds-act.A-qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "iab:BottlingDate" THEN assign tt-gds-act.A-bottleDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "iab:TTNNumber" THEN assign tt-gds-act.A-ttnNumber = hText:node-value no-error .
        IF hNoderef:NAME = "iab:TTNDate" THEN assign tt-gds-act.A-ttnDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "iab:EGAISFixNumber" THEN assign tt-gds-act.A-fixNumber = hText:node-value no-error .
        IF hNoderef:NAME = "iab:EGAISFixDate" THEN assign tt-gds-act.A-fixDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        if available tt-gds-act and tt-gds-act.A-ttnNumber <> ""
        and tt-gds-act.A-ttnNumber <> ? and (tt-gds-act.doc-code = ? or tt-gds-act.doc-code = "")
        then do :
            find first buf_parts no-lock where buf_parts.cst-code = tt-gds-act.A-ttnNumber
                                           and buf_parts.artic = buf_goods.artic
                                            and buf_parts.prod-type = buf_goods.prod-type
                                            and buf_parts.prod-code = buf_goods.prod-code
                                            and buf_parts.obj-type = v-cntxt-obj-type
                                            and buf_parts.obj-code = v-cntxt-obj-code
                                            and buf_parts.out-code = 'free-zone':U
                                            no-error .
            if available buf_parts then do :
                assign
                    tt-gds-act.part-code = buf_parts.part-code
                    tt-gds-act.doc-code  = buf_parts.in-code
                .
            end.
            else do :
                find first ub.doc-attr no-lock where ub.doc-attr.attr-code = 'nids':U and ub.doc-attr.attr-value = tt-gds-act.A-ttnNumber no-error .
                if available ub.doc-attr then do :
                    assign tt-gds-act.doc-code = ub.doc-attr.doc-code .
                end.
                else do :
                    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-gds-act.A-ttnNumber no-error .
                    if available buf_trn-doc then do :
                        assign tt-gds-act.doc-code = buf_trn-doc.doc-code .
                    end.
                end.
            end.
        end.
        IF hNoderef:NAME = "ain:MarkCode"
        OR hNoderef:NAME = "ainp:MarkCode"
        OR hNoderef:NAME = "MarkCode" THEN do :
            create tt-marks.
            assign
                tt-marks.num                    = tt-gds-act.num
                tt-marks.gds-part-position_     = tt-gds-act.position_
                tt-marks.mark                   = hText:node-value
                tt-marks.gds-code               = tt-gds-act.gds-code
                tt-marks.gds-name               = tt-gds-act.gds-name
                tt-marks.alc-code               = tt-gds-act.alc-code
                ii = ii + 1.
            .
            assign tt-gds-act.marks-qnty = ii .
        end.
        run GetChildren (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
define new shared temp-table tt-exts
    field ext-rec as recid
    field gds-code as integer
    index pi as primary unique
        ext-rec gds-code
.
define buffer buf_tt-marks for tt-marks .
define variable select-list as longchar no-undo .
FUNCTION get-mark RETURNS CHARACTER
(buffer local-gds for tt-gds-act ):
if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
                                                           else return "".
end function.
define menu m-add
    menu-item m-goods   label "товары по свободной зоне"
    menu-item m-marks   label "по акцизным маркам"
    menu-item m-one-good label "один товар"
.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-good
     LABEL "Добавить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-marks
     LABEL "Ввести марки"
     SIZE 15 BY 1.14 TOOLTIP "Ввести марки"
     BGCOLOR 8 .
DEFINE BUTTON b-alc-code
     LABEL "Выбор алк. кода"
     SIZE 20 BY 1.14 TOOLTIP "Выбрать алкогольный код"
     BGCOLOR 8 .
DEFINE BUTTON b-del
     LABEL "Удалить строку"
     SIZE 15 BY 1.14 TOOLTIP "Удалить строку акта"
     BGCOLOR 8 .
DEFINE BUTTON b-save
     LABEL "Сохранить"
     SIZE 15 BY 1.14 TOOLTIP "Сохранить в БД"
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.14 .
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".
DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки".
DEFINE QUERY br-gds-act FOR
      tt-gds-act SCROLLING.
DEFINE BROWSE br-gds-act
  QUERY br-gds-act  DISPLAY
    get-mark(BUFFER tt-gds-act) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-act.position_
    tt-gds-act.doc-code
    tt-gds-act.gds-code
    tt-gds-act.alc-code
    tt-gds-act.gds-name
    tt-gds-act.qnty
    tt-gds-act.A-qnty
    tt-gds-act.A-bottleDate
    tt-gds-act.A-ttnNumber
    tt-gds-act.A-ttnDate
    tt-gds-act.A-fixNumber
    tt-gds-act.A-fixDate
    tt-gds-act.marks-qnty
  ENABLE
    tt-gds-act.qnty
    tt-gds-act.A-qnty
    tt-gds-act.A-bottleDate
    tt-gds-act.A-ttnNumber
    tt-gds-act.A-ttnDate
    tt-gds-act.A-fixNumber
    tt-gds-act.A-fixDate
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 20.2 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
    b-cancel at row 1.2 col 2
    b-good at row 1.2 col 32
    b-marks at row 1.2 col 47
    b-alc-code at row 1.2 col 62
    b-del at row 1.2 col 82
    b-save at row 1.2 col 17
    tt-act-header.num at row 2.5 col 2 format "X(22)"
    tt-act-header.date_ at row 2.5 col 34
    tt-act-header.type_ at row 2.5 col 57
        view-as combo-box inner-lines 7
        list-items "Пересортица,Излишки,Продукция полученная до 01.01.2016"
        DROP-DOWN-LIST
    b-mark AT ROW 4 COL 2
    b-sel-all AT ROW 4 COL 5
    b-unmark AT ROW 4 COL 8
    br-gds-act at row 5.2 col 2
     SPACE(0.5) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акт постановки товаров на баланс" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  run proc-b-mark in this-procedure no-error.
END.
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame
DO:
  assign select-list = "".
  if not available tt-gds-act then return.
  for each tt-gds-act no-lock :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid11 as character no-undo .
define variable v-num-entry11 as integer   no-undo .
assign
  v-str-recid11 = trim( string( recid( tt-gds-act ) , "->>>>>>>>>>>9":U ) )
  v-num-entry11 = lookup( v-str-recid11 , select-list )
.
if v-num-entry11 > 0 then do:
  assign
    entry( v-num-entry11, select-list ) = "":U
    select-list = trim( replace( select-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list = select-list + ( if select-list = "":U then "":U else chr(44) ) + v-str-recid11
  .
end.
  end.
  br-gds-act:refresh() in frame Dialog-Frame .
END.
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame
DO:
  if not available tt-gds-act then return.
  select-list  = "".
  br-gds-act:refresh() in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF tt-act-header.type_ IN FRAME Dialog-Frame
DO:
  assign tt-act-header.type_.
  if tt-act-header.type_ = "Пересортица" then do :
      message "Выберите соответствующий акт о списании" view-as alert-box.
      run bge/egais-all-act-writeOff.w (input parparentproc, input yes, output v-RegID ) .
      if v-RegID = ? or v-RegID = "" then do :
        tt-act-header.type_ = "Продукция полученная до 01.01.2016" .
        display tt-act-header.type_  with frame Dialog-Frame.
        message "Акт постановки на баланс с типом 'Пересортица' невозможно отправить без указания соответствующего акта о списании!" view-as alert-box.
      end.
  end.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    if p-mode <> 'ПРОСМОТР':U then do :
        message "Все несохранённые данные будут потеряны. Вы уверены, что хотите выйти?"
        view-as alert-box question buttons yes-no update glog.
        if not glog then return no-apply .
    end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
    define variable v-tt-rec as recid.
    if available tt-gds-act  AND select-list = ""
    then
    select-list = string( recid( tt-gds-act ) ) .
    if not available tt-gds-act and select-list = "" then do :
        message "Выберите строку" view-as alert-box .
        return no-apply.
    end.
    else
    do ii = 1 to num-entries (select-list) :
      v-tt-rec = integer(entry(ii, select-list)) .
      for first tt-gds-act exclusive-lock where recid(tt-gds-act) = v-tt-rec :
        for each tt-marks exclusive-lock where tt-marks.gds-part-position_ = tt-gds-act.position_ :
            delete tt-marks .
        end.
        delete tt-gds-act .
      end.
    end.
    nn = 0 .
    for each tt-gds-act exclusive-lock :
        nn = nn + 1 .
        for each tt-marks exclusive-lock where tt-marks.gds-part-position_ = tt-gds-act.position_ :
            tt-marks.gds-part-position_ = nn .
        end.
        tt-gds-act.position_ = nn .
    end.
    select-list = "" .
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
END.
ON "leave" of tt-act-header.num in FRAME Dialog-Frame
DO:
    define variable prev-num as character no-undo .
    prev-num = tt-act-header.num .
    assign tt-act-header.num .
    for each tt-gds-act exclusive-lock where tt-gds-act.num = prev-num :
        assign tt-gds-act.num = tt-act-header.num .
    end.
    for each tt-marks exclusive-lock where tt-marks.num = prev-num :
        assign tt-marks.num = tt-act-header.num .
    end.
END.
ON CHOOSE OF b-marks IN FRAME Dialog-Frame
DO:
    if not available tt-gds-act then do :
        message "Выберите строку" view-as alert-box .
        return no-apply.
    end.
    run bge/egais-ab-marks.w (parparentproc, tt-gds-act.num, tt-gds-act.position_, tt-gds-act.alc-code, tt-gds-act.qnty, 'ИЗМЕНЕНИЕ':U, input-output table tt-marks) .
    assign ii = 0 .
    for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
        ii = ii + 1 .
    end.
    assign tt-gds-act.marks-qnty = ii .
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    apply "value-changed" to br-gds-act IN FRAME Dialog-Frame .
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
    assign
        tt-act-header.num
        tt-act-header.date_
        tt-act-header.type_
    no-error.
    find first tt-gds-act no-error .
    if not available tt-gds-act then do :
        message "В акте нет строк. Сохранение невозможно" view-as alert-box .
        return no-apply.
    end.
    if can-find(tt-gds-act no-lock where tt-gds-act.qnty < 1 )
    then do :
        message "П Р Е Д У П Р Е Ж Д Е Н И Е" skip
                "В одной или нескольких строках не указано количество." skip
                "Строки с нулевым количеством сохранены не будут!!!" skip
                "Всё равно продолжить сохраненине?" view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    if can-find(tt-gds-act no-lock where tt-gds-act.A-ttnNumber = ? or trim(tt-gds-act.A-ttnNumber) = ""
                                      or tt-gds-act.A-ttnDate = ? or trim(string(tt-gds-act.A-ttnDate)) = "" )
    then do :
        message "П Р Е Д У П Р Е Ж Д Е Н И Е" skip
                "В одной или нескольких строках не заполнены поля   номер/дата ТТН." skip
                "Такой акт не может быть отправлен в ЕГАИС." skip
                "Всё равно продолжить сохраненине?" view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    if can-find(tt-gds-act no-lock where tt-gds-act.A-bottleDate = ? or trim(string(tt-gds-act.A-bottleDate)) = "" )
    then do :
        message "П Р Е Д У П Р Е Ж Д Е Н И Е" skip
                "В одной или нескольких строках не заполнено поле   дата розлива." skip
                "Такой акт не может быть отправлен в ЕГАИС." skip
                "Всё равно продолжить сохраненине?" view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    if can-find(tt-gds-act no-lock where tt-gds-act.A-fixDate = ? or trim(string(tt-gds-act.A-fixDate)) = "" )
    then do :
        message "П Р Е Д У П Р Е Ж Д Е Н И Е" skip
                "В одной или нескольких строках не заполнено поле   дата фиксации в ЕГАИС." skip
                "Всё равно продолжить сохраненине?" view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    run makeXML_TH in this-procedure no-error.
    if error-status:error then return return-value .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + chr(4) + string(tt-act-header.date_) + chr(4)
               + string(tt-act-header.is-sent) + chr(4) + tt-act-header.answer_ + chr(4) + tt-act-header.type_
    .
    find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = tt-act-header.num
                                              and buf_clob-bind.field-name_  = 'egais-ab':U no-error .
    if available buf_clob-bind then do :
        if p-mode = 'ДОБАВЛЕНИЕ':U then do :
            message "Акт с таким номером уже существует!" view-as alert-box .
            return no-apply .
        end.
        assign
            v-clob-db-num = buf_clob-bind.db-num
            v-int64-id = buf_clob-bind.int64-id
            v-part-num = buf_clob-bind.part-num
        .
        run gbl/file2clb.p ( input 'ИЗМЕНЕНИЕ':U
                  ,input "add-new,yes"
                  ,input ?
                  ,input tt-act-header.num
                  ,input 'egais-ab':U
                  ,input v-info
                  ,input-output v-part-num
                  ,input 'egais-ab':U
                  ,input-output v-clob-db-num
                  ,input-output v-int64-id
                  ,input search (v-file)
                  ,input ''
                  ) no-error .
         if error-status:error then message return-value view-as alert-box.
    end.
    else do :
        run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                  ,input ",yes"
                  ,input ?
                  ,input tt-act-header.num
                  ,input 'egais-ab':U
                  ,input v-info
                  ,input-output v-part-num
                  ,input 'egais-ab':U
                  ,input-output v-clob-db-num
                  ,input-output v-int64-id
                  ,input search (v-file)
                  ,input ''
                  ) no-error .
    end.
    message "Сохранение завершено" view-as alert-box.
END.
on choose of menu-item m-goods in menu m-add
DO:
    define variable v-user-action    as character no-undo.
    define variable v-printed        as logical   no-undo.
    run ref/gds-ref.p
    ( parparentproc
    ,'b-sel,b-mark,b-add'
    ,?
    ,?
    ,'свободно':U
    ,?
    ,?
    ,?
    ,?
    ,v-cntxt-obj-type
    ,v-cntxt-obj-code
    ,?
    , output v-rid-list) no-error.
    if v-rid-list = "" or v-rid-list = ?
    then return no-apply.
    if search ("act-bal_log.err") <> ? then do:
      os-delete value("act-bal_log.err").
    end.
    output stream str-log to value("act-bal_log.err") append .
    err-good = false .
    _goods_ :
    do jj = 1 to num-entries(v-rid-list) :
        find buf_goods where recid (buf_goods) = integer(entry(jj, v-rid-list)) no-lock.
        run gds-attr-value(
          buf_goods.gds-code,
          'alcohol-prod':U,
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then
        do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  товар " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  не является алкогольной продукцией" skip.
            err-good = true .
            next _goods_ .
        end.
        run gen-key-rec IN THIS-PROCEDURE ( input 'goods':U
                                            ,input (buffer buf_goods:handle)
                                            ,output v-gds-uniq-key-rec).
        exts = 0 .
        for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                       and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                       AND X_ext-classif.db-num = 0
                                       and X_ext-classif.key#_one = buf_goods.gds-code
                                       and X_ext-classif.key#_two = v-ext-sys
                                       and X_ext-classif.key#_three = 0
                                       and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                       and X_eXt-classif.charkey_two = ""
                                       and X_eXt-classif.charkey_three = ""
                                       and X_eXt-classif.nonunique = 0 :
            find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
            if not available tt-exts then do :
                create tt-exts .
                assign
                    tt-exts.ext-rec = recid(x_ext-classif)
                    tt-exts.gds-code = buf_goods.gds-code
                .
            end.
            exts = exts + 1 .
        end.
        if exts = 0 then do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  товар " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  не синхронизирован с ЕГАИС" skip.
            err-good = true .
            next _goods_ .
        end.
        else do :
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_one = buf_goods.gds-code
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                               and X_eXt-classif.charkey_two = ""
                                               and X_eXt-classif.charkey_three = ""
                                               and X_eXt-classif.nonunique = 0
                                               .
        end.
        find first buf_parts no-lock where buf_parts.artic = buf_goods.artic
                                    and buf_parts.prod-type = buf_goods.prod-type
                                    and buf_parts.prod-code = buf_goods.prod-code
                                    and buf_parts.obj-type = v-cntxt-obj-type
                                    and buf_parts.obj-code = v-cntxt-obj-code
                                    and buf_parts.out-code = 'free-zone':U no-error .
        if not available buf_parts  then do :
            put stream str-log unformatted
                string(today) + "   " + string(time, "hh:mm:ss") + " :  у товара " + string(buf_goods.gds-code) + "  " + buf_goods.gds-name + "  нет партий свободной зоны" skip.
            err-good = true .
            next _goods_ .
        end.
        _parts_ :
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic
                                    and buf_parts.prod-type = buf_goods.prod-type
                                    and buf_parts.prod-code = buf_goods.prod-code
                                    and buf_parts.obj-type = v-cntxt-obj-type
                                    and buf_parts.obj-code = v-cntxt-obj-code
                                    and buf_parts.out-code = 'free-zone':U ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.in-code :
            if buf_parts.qnty <= 0 then next _parts_ .
            assign nn = nn + 1 .
            create tt-gds-act.
            assign
                tt-gds-act.gds-code         = buf_goods.gds-code
                tt-gds-act.alc-code         = X_ext-classif.charkey_one
                tt-gds-act.gds-name         = buf_goods.gds-name
                tt-gds-act.doc-code         = buf_trn-doc.doc-code
                tt-gds-act.doc-date         = buf_trn-doc.fact-date
                tt-gds-act.num              = tt-act-header.num
                tt-gds-act.part-code        = buf_parts.part-code
                tt-gds-act.position_        = nn
                tt-gds-act.qnty             = buf_parts.qnty
                tt-gds-act.marks-qnty       = 0
                tt-gds-act.A-bottleDate     = buf_parts.alc-bottling-date
                tt-gds-act.A-qnty           = buf_parts.qnty
            .
            find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                   and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                   and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                   and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                   and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                   and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                   and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                   and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                   and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                   and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                   and X_ext-classif-attr.attr-code = 'egais-info'
                                                   no-error .
            if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
            if buf_parts.cst-code <> "" then do :
                assign tt-gds-act.A-ttnNumber      = buf_parts.cst-code .
            end.
            else do :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
                if v-attr-value <> "" and v-attr-value <> ? then do :
                    assign tt-gds-act.A-ttnNumber  =  v-attr-value .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
                    assign tt-gds-act.A-ttnDate = if v-attr-value = "" or v-attr-value = ? then buf_trn-doc.doc-date else date( v-attr-value ) .
                end.
                else do :
                    assign
                        tt-gds-act.A-ttnNumber  = buf_trn-doc.doc-code
                        tt-gds-act.A-ttnDate    = buf_trn-doc.doc-date
                    .
                end.
            end.
        end.
    end.
    output stream str-log close .
    if err-good then do :
        message "Не все выбранные товары добавлены в акт!" view-as alert-box .
        run gbl/prnfilen.w
           (input  "Ошибки при добавлении товаров"
           ,input  0
           ,input  "act-bal_log.err"
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).
    end.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    apply "value-changed" to br-gds-act IN FRAME Dialog-Frame .
END.
on choose of menu-item m-marks in menu m-add
DO:
    run bge/egais-ab-marks.w (parparentproc, tt-act-header.num, ?, "", 0, 'ИЗМЕНЕНИЕ':U, input-output table tt-marks) .
    for each tt-marks exclusive-lock where tt-marks.gds-part-position_ = ? and tt-marks.num = tt-act-header.num :
        find first tt-gds-act exclusive-lock where tt-gds-act.alc-code = tt-marks.alc-code no-error .
        if not available tt-gds-act then do :
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-marks.alc-code
                                               and X_eXt-classif.charkey_two = ""
                                               and X_eXt-classif.charkey_three = ""
                                               and X_eXt-classif.nonunique = 0
                                               .
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
            nn = nn + 1 .
            create tt-gds-act .
            assign
                tt-gds-act.gds-code         = buf_goods.gds-code
                tt-gds-act.alc-code         = X_ext-classif.charkey_one
                tt-gds-act.gds-name         = buf_goods.gds-name
                tt-gds-act.num              = tt-act-header.num
                tt-gds-act.position_        = nn
                tt-gds-act.marks-qnty       = 0
            .
            find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                   and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                   and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                   and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                   and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                   and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                   and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                   and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                   and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                   and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                   and X_ext-classif-attr.attr-code = 'egais-info'
                                                   no-error .
            if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
        end.
        if not can-find(buf_tt-marks where buf_tt-marks.mark = tt-marks.mark
                                       and buf_tt-marks.gds-part-position_ <> ?)
        then
        assign
            tt-marks.gds-part-position_ = tt-gds-act.position_
            tt-gds-act.marks-qnty       = tt-gds-act.marks-qnty + 1
            tt-gds-act.A-qnty           = tt-gds-act.A-qnty + 1
            tt-gds-act.qnty             = tt-gds-act.qnty + 1
        .
    end.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    apply "value-changed" to br-gds-act IN FRAME Dialog-Frame .
END.
on choose of menu-item m-one-good in menu m-add
DO:
    run ref/gds-ref.p
    ( parparentproc
    ,'b-sel,b-add'
    ,?
    ,?
    ,'все':U
    ,?
    ,?
    ,?
    ,?
    ,v-cntxt-obj-type
    ,v-cntxt-obj-code
    ,?
    , output v-rid-list) no-error.
    if v-rid-list = "" or v-rid-list = ?
    then return no-apply.
    find buf_goods where recid (buf_goods) = integer(v-rid-list) no-lock.
    run gds-attr-value(
      buf_goods.gds-code,
      'alcohol-prod':U,
      output par-alcohol,
      output par-type
    ).
    if par-alcohol = "" or par-alcohol = "no" then
    do :
        message "Выбранный товар не является алкогольной продукцией." view-as alert-box.
        return no-apply .
    end.
    run gen-key-rec IN THIS-PROCEDURE ( input 'goods':U
                                        ,input (buffer buf_goods:handle)
                                        ,output v-gds-uniq-key-rec).
    exts = 0 .
    for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                       and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                       AND X_ext-classif.db-num = 0
                                       and X_ext-classif.key#_one = buf_goods.gds-code
                                       and X_ext-classif.key#_two = v-ext-sys
                                       and X_ext-classif.key#_three = 0
                                       and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                       and X_eXt-classif.charkey_two = ""
                                       and X_eXt-classif.charkey_three = ""
                                       and X_eXt-classif.nonunique = 0 :
        find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
        if not available tt-exts then do :
            create tt-exts .
            assign
                tt-exts.ext-rec = recid(X_ext-classif)
                tt-exts.gds-code = buf_goods.gds-code
            .
        end.
        exts = exts + 1 .
    end.
    if exts = 0 then do :
        message "Выбранный товар не синхронизирован с ЕГАИС. (Нет алкогольного кода)" view-as alert-box.
        return no-apply.
    end.
    else if exts = 1 then do :
        find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                           and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_one = buf_goods.gds-code
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                           and X_eXt-classif.charkey_two = ""
                                           and X_eXt-classif.charkey_three = ""
                                           and X_eXt-classif.nonunique = 0
                                           .
    end.
    else do :
        run bge/egais-select-alc-code.w (input buf_goods.gds-code, output p-ext-rec) .
        find first X_ext-classif no-lock where recid(X_ext-classif) = p-ext-rec no-error .
        if not available X_ext-classif then return no-apply.
    end.
    nn = nn + 1 .
    create tt-gds-act .
    assign
        tt-gds-act.gds-code         = buf_goods.gds-code
        tt-gds-act.alc-code         = X_ext-classif.charkey_one
        tt-gds-act.gds-name         = buf_goods.gds-name
        tt-gds-act.num              = tt-act-header.num
        tt-gds-act.position_        = nn
        tt-gds-act.marks-qnty       = 0
    .
    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                           no-error .
    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
    open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
    apply "value-changed" to br-gds-act IN FRAME Dialog-Frame .
END.
on choose of b-alc-code IN FRAME Dialog-Frame
do :
    if not available tt-gds-act then return no-apply .
    run bge/egais-select-alc-code.w (input tt-gds-act.gds-code, output p-ext-rec) .
    find first X_ext-classif no-lock where recid(X_ext-classif) = p-ext-rec no-error .
    if not available X_ext-classif then return no-apply.
    assign tt-gds-act.alc-code = X_ext-classif.charkey_one .
    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                           no-error .
    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.
    br-gds-act:refresh() .
end.
on row-display of br-gds-act in FRAME Dialog-Frame
DO :
    exts = 0 .
    for each tt-exts no-lock where tt-exts.gds-code = tt-gds-act.gds-code :
        exts = exts + 1 .
    end.
    if exts > 1 then tt-gds-act.alc-code:bgcolor in browse br-gds-act = yellow_color .
end.
on value-changed of br-gds-act IN FRAME Dialog-Frame
DO :
if available tt-gds-act then do :
    exts = 0 .
    for each tt-exts no-lock where tt-exts.gds-code = tt-gds-act.gds-code :
        exts = exts + 1 .
    end.
    if exts > 1
    and not can-find(tt-marks where tt-marks.alc-code = tt-gds-act.alc-code)
    then enable b-alc-code WITH FRAME Dialog-Frame.
    else disable b-alc-code WITH FRAME Dialog-Frame.
end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
        b-good:popup-menu in frame Dialog-Frame = menu m-add:handle
        b-good:menu-mouse = 1
        nn = 0
        tt-act-header.type_:list-items = "Пересортица,Излишки,Продукция полученная до 01.01.2016"
    .
    empty temp-table tt-exts .
    if p-mode = 'ДОБАВЛЕНИЕ':U then do :
        v-date = substitute ("&1&2&3", string (day (now), "99"), string (month (now), "99"),substring (string(year (now)), 3,2)).
        create tt-act-header .
        assign
            tt-act-header.num = "ACO-" + v-date + '-' + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + '-' + string(int(TIME))
            tt-act-header.date_ = TODAY
            tt-act-header.is-sent = no
            tt-act-header.type_ = "Продукция полученная до 01.01.2016"
        .
        display tt-act-header.num tt-act-header.date_ with frame Dialog-Frame.
        enable  tt-act-header.date_ b-good with frame Dialog-Frame.
        if egais:VerXSD = "2" then do :
            display tt-act-header.type_ with frame Dialog-Frame.
            enable  tt-act-header.type_ with frame Dialog-Frame.
        end.
        else hide tt-act-header.type_ in frame Dialog-Frame.
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U then do :
        find last buf_clob-bind where buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value
                                  and buf_clob-bind.field-name_ = 'egais-ab':U
                                  and buf_clob-bind.part-num = 1  .
        find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
        copy-lob
        from  object buf_clob-data.cdata
        to  file 'temp.xml'
        no-convert
        no-error .
        empty temp-table tt-marks no-error .
        run parseXML in this-procedure .
        display tt-act-header.num tt-act-header.date_ with frame Dialog-Frame.
        if egais:VerXSD = "2" then do :
            display tt-act-header.type_ with frame Dialog-Frame.
            if p-mode = 'ИЗМЕНЕНИЕ':U then enable  tt-act-header.type_ with frame Dialog-Frame.
        end.
        if p-mode = 'ИЗМЕНЕНИЕ':U then
        for each tt-gds-act no-lock :
            nn = nn + 1 .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if not available buf_goods then do :
                message "По алкогольному коду " tt-gds-act.alc-code " не найден товар из TH. Вероятно, кто-то удалил связку." view-as alert-box.
                next.
            end.
            run gen-key-rec IN THIS-PROCEDURE ( input 'goods':U
                                            ,input (buffer buf_goods:handle)
                                            ,output v-gds-uniq-key-rec).
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                           and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_one = buf_goods.gds-code
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                           and X_eXt-classif.charkey_two = ""
                                           and X_eXt-classif.charkey_three = ""
                                           and X_eXt-classif.nonunique = 0 :
                find first tt-exts no-lock where tt-exts.ext-rec = recid(x_ext-classif)
                                         and tt-exts.gds-code = buf_goods.gds-code no-error.
                if not available tt-exts then do :
                    create tt-exts .
                    assign
                        tt-exts.ext-rec = recid(X_ext-classif)
                        tt-exts.gds-code = tt-gds-act.gds-code
                    .
                end.
            end.
        end .
        open QUERY br-gds-act FOR each tt-gds-act exclusive-lock .
        if p-mode = 'ПРОСМОТР':U then disable b-good with frame Dialog-Frame.
        else enable b-good with frame Dialog-Frame.
    end.
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
        v-diasize-browse-handle     = browse br-gds-act :handle
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
    RUN enable_UI.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE proc-b-mark :
  define variable varlog as logical   no-undo .
  if not available tt-gds-act then return.
  run local-mark in this-procedure.
  assign varlog = br-gds-act :select-next-row( ) in frame Dialog-Frame.
  apply "ENTRY":U to br-gds-act in frame Dialog-Frame.
  br-gds-act:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE local-mark :
  if not available tt-gds-act then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid14 as character no-undo .
define variable v-num-entry14 as integer   no-undo .
assign
  v-str-recid14 = trim( string( recid( tt-gds-act ) , "->>>>>>>>>>>9":U ) )
  v-num-entry14 = lookup( v-str-recid14 , select-list )
.
if v-num-entry14 > 0 then do:
  assign
    entry( v-num-entry14, select-list ) = "":U
    select-list = trim( replace( select-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list = select-list + ( if select-list = "":U then "":U else chr(44) ) + v-str-recid14
  .
end.
  br-gds-act:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-cancel b-marks b-save br-gds-act b-del b-mark b-sel-all b-unmark
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
    if p-mode = 'ПРОСМОТР':U then do :
        disable  tt-act-header.num tt-act-header.date_ with frame Dialog-Frame.
        define variable hCol as handle no-undo .
        define variable hBr  as handle no-undo .
        define variable i    as integer no-undo .
        hBr = browse br-gds-act:handle .
        do i = 7 to 13 :
            hCol = hBr:GET-BROWSE-COLUMN(i).
            hCol:read-only = true .
        end.
        hide b-good b-marks b-save b-del b-alc-code in FRAME Dialog-Frame.
    end.
END PROCEDURE.
