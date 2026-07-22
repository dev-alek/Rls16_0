block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input parameter p-xsd-file as character no-undo .
define input parameter p-rebh as handle no-undo .
define output parameter p-dataseth as handle no-undo.
define output parameter p-xmlh as handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ptdysa.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ptdysa.p $":U .
define variable vss-description as character no-undo init "ДИНАМИКА ПРОДАЖ НА АЗС по текущей смене".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info1 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info1, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info1, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info1 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info1, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info1, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info1, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info1, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info1, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info1, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info1, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
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
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info2
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info2
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info2 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info2 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info2 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info2 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info2 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info2 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info2 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info2 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define temp-table obj-dyn-salt no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field current-datetime as datetime
field report-num as integer
index pi is unique primary
obj-type
obj-code
.
define temp-table cd-dyn-salt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field cash-num as integer
field start-date as date
field start-time as integer
field end-date as date
field end-time as integer
field report-num as integer
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
cash-num
.
define temp-table grp-dyn-salt no-undo
field node-code as integer
field full-name as character
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
node-code
.
define temp-table gds-dyn-salt no-undo
field gds-code as integer
field node-code as integer
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field unit-base as character
field gds-name as character
field fact-qnty as decimal
field fact-sum as decimal
field is-petrol as logical
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
index igrp
obj-type
obj-code
shift-date
shift-num
node-code
.
define dataset report-ptdysa-dst
for report-headert, report-parameterst, report-errorst,  obj-dyn-salt, cd-dyn-salt, grp-dyn-salt, gds-dyn-salt
data-relation r1 for obj-dyn-salt, grp-dyn-salt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for grp-dyn-salt, gds-dyn-salt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, node-code, node-code) nested
data-relation r3 for obj-dyn-salt, cd-dyn-salt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
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
procedure rep-clb_fill-report-xml :
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field-name_ as character no-undo .
define input parameter p-dataseth as handle no-undo .
define output parameter p-db-num-list as character no-undo .
define output parameter p-int64-id-list as character no-undo .
define output parameter p-part-num-list as character no-undo .
define variable v-longchar as longchar no-undo .
define variable glog as logical no-undo .
define buffer buf_clob-bind for ub.clob-bin.
define buffer buf_clob-data for ub.clob-data.
for each buf_clob-bind no-lock where
          buf_clob-bind.uniq-key-rec = p-uniq-key-rec
      and buf_clob-bind.field-name_ = p-field-name_
      and buf_clob-bind.resource-type = 'report-xml':U
by buf_clob-bind.uniq-key-rec
by buf_clob-bind.field-name_
by buf_clob-bind.part-num:
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if not available buf_clob-data then do:
    undo, return error substitute("Отсутствует CLOB-DATA (БД &1 id &2) для имеющегося CLOB-BIND:&3" +
                                  "ресурс типа &4 объект &5 файл № &6"
                                  ,buf_clob-bind.db-num
                                  ,buf_clob-bind.int64-id
                                  ,chr(10)
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ,buf_clob-bind.part-num) .
  end.
  v-longchar = ''.
  COPY-LOB FROM object buf_clob-data.cdata
  to OBJECT v-longchar NO-ERROR .
  assign
  p-part-num-list = p-part-num-list +
                    (if p-part-num-list = '' then '' else chr(44)) +
                    string(buf_clob-bind.part-num)
  p-db-num-list = p-db-num-list +
              (if p-db-num-list = '' then '' else chr(44)) +
              string(buf_clob-bind.db-num)
  p-int64-id-list = p-int64-id-list +
              (if p-int64-id-list = '' then '' else chr(44)) +
              string(buf_clob-bind.int64-id)
  .
  glog = p-dataseth:READ-XML("LONGCHAR"
                              ,v-longchar
                              ,"append"
                              ,?
                              ,?
                              ,?
                              ,"LOOSE") no-error.
  v-longchar = ''.
  if error-status:error
  then do:
    undo, return error substitute("&1&2Ошибка при заполнении датасета данными&2" +
                                    "отчет ID &3 срез &4"
                                    ,vss-include-info8
                                    ,chr(10)
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ).
  end.
  if not glog then do:
    undo, return error substitute("&1&2Ошибка при заполнении датасета данными&2" +
                                    "отчет ID &3 срез &4"
                                    ,vss-include-info8
                                    ,chr(10)
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ).
  end.
end.
v-longchar = ''.
end procedure.
procedure rep-clb_save-rep-xml :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field-name_ as character no-undo .
define input parameter p-part-num-list as character no-undo .
define input parameter p-clob-db-num-list as character no-undo .
define input parameter p-int64-id-list as character no-undo .
define input parameter p-locked-rec-handle as handle no-undo .
define input parameter p-descr as character no-undo .
define input parameter p-nws as logical no-undo .
define input parameter p-encoding as character no-undo .
define input parameter p-dataseth as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-clob-db-num as integer no-undo .
define variable v-part-num as integer no-undo .
define variable v-int64-id as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-num-entries as integer no-undo .
do
on error undo, return error
:
  if p-part-num-list = "" then do:
    assign
    p-part-num-list = string(0)
    p-clob-db-num-list = ''
    p-int64-id-list = string(0)
    .
  end.
  do v-ii = 1 to num-entries(p-part-num-list):
    run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name).
    p-dataseth:write-xml("file"
                        ,v-file-name
                        ,yes
                        ,(if p-encoding = "1251" then "windows-1251" else p-encoding)
                        ,?
                        ,no
                        ,no
                        ).
    assign
    v-part-num = integer(entry(v-ii, p-part-num-list))
    v-clob-db-num = (if entry(v-ii, p-clob-db-num-list) = ''
                     then ?
                     else integer(entry(v-ii, p-clob-db-num-list)))
    v-int64-id = int64(entry(v-ii, p-int64-id-list))
    .
    run gbl/file2clb.p ( input (if v-clob-db-num = ?
                                then 'ДОБАВЛЕНИЕ':U
                                else 'ИЗМЕНЕНИЕ':U)
                        ,input ("override" +
                                (if p-nws = no
                                 then (chr(44) + string(no))
                                 else "")
                                )
                        ,input p-locked-rec-handle
                        ,input p-uniq-key-rec
                        ,input p-field-name_
                        ,input p-descr
                        ,input-output v-part-num
                        ,input 'report-xml':U
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input v-file-name
                        ,input p-encoding
                        ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1&2Ошибка при сохранении в БД отчета ID &3 срез &4"
                                      ,vss-include-info8
                                      ,chr(10)
                                    , p-uniq-key-rec
                                    , p-field-name_
                                    ).
    end.
    os-delete value(v-file-name).
  end.
end.
end procedure.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
define temp-table temp-obj no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field report-num as integer
field db-num-list as character
field int64-id-list as character
field part-num-list as character
field rule-id as character
field field-name_ as character
field dataset-size as int64
index pi is unique primary
obj-type
obj-code
.
define variable l-shift-on as logical no-undo .
define variable v-full-name as character no-undo .
define variable v-is-petrol  as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-start-chk-date as date no-undo .
define variable v-start-chk-time as integer no-undo .
define variable v-end-chk-date as date no-undo .
define variable v-end-chk-time as integer no-undo .
define variable v-shift-id as character no-undo .
define variable v-part-num-list as character no-undo .
define variable v-db-num-list as character no-undo .
define variable v-int64-id-list as character no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-longchar as longchar no-undo .
define variable v_obj-dataseth as handle no-undo .
define variable v-gate-rec as character no-undo .
define variable glog as logical no-undo .
define variable v-current-cash-num as integer   no-undo .
define variable v-task-num as integer no-undo .
define variable v-write-err as logical no-undo .
define variable v-fix-start-date as date no-undo .
define variable v-fix-start-time as integer no-undo.
define variable v-fix-end-date as date no-undo .
define variable v-fix-end-time as integer no-undo.
define variable v-report-num as integer no-undo .
define variable v-current-datetime as datetime no-undo .
define variable v-obj-address as character no-undo .
define variable v-obj-phone as character no-undo .
define buffer buf_temp-obj for temp-obj.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_clients for ub.clients.
define buffer buf_gds-dyn-salt for gds-dyn-salt.
define buffer buf_grp-dyn-salt for grp-dyn-salt.
define buffer buf_obj-dyn-salt for obj-dyn-salt.
define buffer buf_cd-dyn-salt for cd-dyn-salt.
define buffer buf_temp-xml-tables for temp-xml-tables.
if lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0 then do:
  v-write-err = yes.
end.
p-xmlh = buffer buf_temp-xml-tables:handle.
run get-gate-rec in this-procedure ( input p-xsd-file
                                    ,output v-gate-rec) no-error.
if error-status:error then do:
  undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", p-xsd-file).
end.
run get-gate-by-rec in this-procedure ( input v-gate-rec
                                      ,output p-dataseth
                                      ,input-output p-xmlh
                                      ,input-output v-longchar
                                      ) no-error.
if error-status:error then do:
    run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4"                             , v-gate-rec                             , chr(10)                             , error-status:get-message(1)                             , return-value )).
  delete object p-dataseth no-error.
  undo, return error '':U.
end.
for each buf_clients no-lock where
        buf_clients.db-num = g#db-num
    and buf_clients.stts = integer('0':U)
    and buf_clients.obj-type = 'маг':U:
  find first buf_temp-obj no-lock where
          buf_temp-obj.obj-type = buf_clients.obj-type
      and buf_temp-obj.obj-code = buf_clients.obj-code no-error.
  if not available buf_temp-obj then do:
    create buf_temp-obj.
    assign
    buf_temp-obj.obj-type = buf_clients.obj-type
    buf_temp-obj.obj-code = buf_clients.obj-code
    buf_temp-obj.obj-name = buf_clients.obj-name
    buf_temp-obj.db-num = buf_clients.db-num
    .
    release buf_temp-obj.
  end.
end.
v_obj-dataseth = dataset report-ptdysa-dst:handle.
_temp-obj:
for each buf_temp-obj :
  l-shift-on = no.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_temp-obj.obj-type
  ,input  buf_temp-obj.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
  if not l-shift-on then do:
    delete buf_temp-obj.
    next _temp-obj.
  end.
  assign
  v-obj-address = ''
  v-obj-phone = ''
  .
  RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_temp-obj.obj-type
                                          , INPUT  buf_temp-obj.obj-code
                                          ) .
  assign
  v-obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                            + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
  v-obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_temp-obj.obj-type
  ,input  buf_temp-obj.obj-code
  ,output buf_temp-obj.shift-date
  ,output buf_temp-obj.shift-num
  ,output buf_temp-obj.shift-name
  ) no-error .
  if error-status:error
  or
  buf_temp-obj.shift-date = ? then do:
    find last buf_shift-obj
      where buf_shift-obj.obj-type = buf_temp-obj.obj-type
        and buf_shift-obj.obj-code = buf_temp-obj.obj-code
        and buf_shift-obj.status_ = 'зкр':U
      use-index stts
      no-error .
    if available buf_shift-obj then do:
      assign
      buf_shift-obj.shift-date = buf_shift-obj.shift-date
      buf_shift-obj.shift-num = buf_shift-obj.shift-num
      buf_shift-obj.shift-name = buf_shift-obj.shift-name
      .
    end.
  end.
  if buf_temp-obj.shift-date = ? then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену - пропускаем ...."                                   , buf_temp-obj.obj-type                                   , buf_temp-obj.obj-code )).
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '1':U
                                                    ,input substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену - пропускаем ...."                                   , buf_temp-obj.obj-type                                   , buf_temp-obj.obj-code )).
    end.
    delete buf_temp-obj.
    next _temp-obj.
  end.
  if not available buf_shift-obj then do:
    find first buf_shift-obj no-lock where
            buf_shift-obj.obj-type = buf_temp-obj.obj-type
        and buf_shift-obj.obj-code = buf_temp-obj.obj-code
        and buf_shift-obj.shift-date = buf_temp-obj.shift-date
        and buf_shift-obj.shift-num = buf_temp-obj.shift-num no-error.
    if not available buf_shift-obj then do:
            if v-write-err then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input '1':U
                                                      ,input substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену &3 П. &4 - пропускаем ...."                                     , buf_temp-obj.obj-type                                     , buf_temp-obj.obj-code                                     , string(buf_temp-obj.shift-date, "99/99/9999")                                     , string(buf_temp-obj.shift-num))).
      end.
      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену &3 П. &4 - пропускаем ...."                                     , buf_temp-obj.obj-type                                     , buf_temp-obj.obj-code                                     , string(buf_temp-obj.shift-date, "99/99/9999")                                     , string(buf_temp-obj.shift-num))).
      delete buf_temp-obj.
      next _temp-obj.
    end.
  end.
  v-shift-id = substitute("&1&2.&3.&4"
                         , buf_temp-obj.obj-type
                         , buf_temp-obj.obj-code
                         , buf_temp-obj.shift-date
                         , buf_temp-obj.shift-num).
  assign
  v-part-num-list = ''
  v-db-num-list = ''
  v-int64-id-list = ''
  .
  v_obj-dataseth:empty-dataset().
  run rep-clb_fill-report-xml in this-procedure ( input p-report-id
                                                 ,input v-shift-id
                                                 ,input v_obj-dataseth
                                                 ,output v-db-num-list
                                                 ,output v-int64-id-list
                                                 ,output v-part-num-list
                                                 ) no-error.
  if error-status:error then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Ошибка при получении данных предыдущего среза отчета:&1&2&1&3"                                , chr(10)                                , error-status:get-message(1)                                 , return-value )).
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '2':U
                                                    ,input substitute("Ошибка при получении данных предыдущего среза отчета:&1&2&1&3"                                , chr(10)                                , error-status:get-message(1)                                 , return-value )).
    end.
    v_obj-dataseth:empty-dataset().
  end.
  assign
  buf_temp-obj.db-num-list = v-db-num-list
  buf_temp-obj.int64-id-list = v-int64-id-list
  buf_temp-obj.part-num-list = v-part-num-list
  buf_temp-obj.rule-id  = p-report-id
  buf_temp-obj.field-name_ = v-shift-id
  .
  v-current-cash-num = - 1.
  run cur-time in this-procedure ( output v-today, output v-time).
  v-current-datetime =  cur-time-datetime ().
  _chk-doc:
  for each buf_chk-doc no-lock where
         buf_chk-doc.obj-type = buf_temp-obj.obj-type
     and buf_chk-doc.obj-code = buf_temp-obj.obj-code
     and buf_chk-doc.chk-date >= buf_temp-obj.shift-date
  by buf_chk-doc.obj-type
  by buf_chk-doc.obj-code
  by buf_chk-doc.pay-desk:
    if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then NEXT _chk-doc.
    if buf_chk-doc.chk-date > v-today
    or (buf_chk-doc.chk-date = v-today
        and
        buf_chk-doc.chk-time = v-time) then next _chk-doc.
    if (buf_chk-doc.shift-date = buf_temp-obj.shift-date
    and buf_chk-doc.shift-num = buf_temp-obj.shift-num)
    or (lookup('смн-ош':U, buf_chk-doc.office) > 0
        and buf_chk-doc.chk-date >= buf_chk-doc.shift-date
    and  buf_chk-doc.shift-num = 0) then do:
      if v-current-cash-num <> buf_chk-doc.pay-desk then do:
        release buf_cd-dyn-salt no-error .
        if v-current-cash-num > -1 then do:
          find first buf_cd-dyn-salt where
                    buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
                and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
                and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
                and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
                and buf_cd-dyn-salt.cash-num = v-current-cash-num no-error.
          assign
          buf_cd-dyn-salt.end-date = v-fix-end-date
          buf_cd-dyn-salt.end-time = v-fix-end-time
          buf_cd-dyn-salt.start-date = v-fix-start-date
          buf_cd-dyn-salt.start-time = v-fix-start-time
          .
        end.
        find first buf_cd-dyn-salt where
                  buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
              and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
              and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
              and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
              and buf_cd-dyn-salt.cash-num = buf_chk-doc.pay-desk no-error.
        if not available buf_cd-dyn-salt then do:
          create buf_cd-dyn-salt.
          assign
          buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
          buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
          buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
          buf_cd-dyn-salt.cash-num = buf_chk-doc.pay-desk
          buf_cd-dyn-salt.start-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.start-time = 0
          buf_cd-dyn-salt.end-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.end-time = -1
          buf_cd-dyn-salt.report-num = 0
          .
        end.
        assign
        v-start-chk-date = buf_cd-dyn-salt.start-date
        v-start-chk-time = buf_cd-dyn-salt.start-time
        v-end-chk-date = buf_cd-dyn-salt.end-date
        v-end-chk-time = buf_cd-dyn-salt.end-time
        v-fix-start-date = buf_cd-dyn-salt.start-date
        v-fix-start-time = buf_cd-dyn-salt.start-time
        v-fix-end-date = buf_cd-dyn-salt.end-date
        v-fix-end-time = buf_cd-dyn-salt.end-time
        buf_cd-dyn-salt.report-num = buf_cd-dyn-salt.report-num + 1
        v-current-cash-num = buf_chk-doc.pay-desk
        v-report-num = buf_cd-dyn-salt.report-num
        .
      end.
      if ((buf_chk-doc.chk-date = v-end-chk-date
            and buf_chk-doc.chk-time > v-end-chk-time)
            or
            buf_chk-doc.chk-date > v-end-chk-date)
       then do:
         if buf_chk-doc.chk-date > v-fix-end-date
         or (buf_chk-doc.chk-date = v-fix-end-date
             and
             buf_chk-doc.chk-time > v-fix-end-time)  then do:
          assign
          v-fix-end-date = buf_chk-doc.chk-date
          v-fix-end-time = buf_chk-doc.chk-time
          .
         end.
         if buf_chk-doc.chk-date < v-fix-start-date
         or (buf_chk-doc.chk-date < v-fix-start-date
             and
             buf_chk-doc.chk-time < v-fix-start-time) then do:
          assign
          v-fix-start-date = buf_chk-doc.chk-date
          v-fix-start-time = buf_chk-doc.chk-time
          .
         end.
         _chk-gds:
         for each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code,
             first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code:
           find first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code no-error.
           if not available buf_goods then do:
                          run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Не найден товар с кодом &1", buf_bar-code.gds-code)).
             if v-write-err then do:
               run cb_write-report-error in p-parent-handle ( input p-rebh
                                                             ,input p-report-id
                                                             ,input ?
                                                             ,input '2':U
                                                             ,input substitute("!!!Не найден товар с кодом &1", buf_bar-code.gds-code)).
             end.
             next _chk-gds.
           end.
           find first buf_gds-grp no-lock where
                    buf_gds-grp.node-code = buf_goods.grp-code no-error.
          if available buf_gds-grp then do:
            run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code
                                                        ,output v-full-name) no-error.
            if error-status:error then do:
              assign
              v-full-name = substitute("_Группа с вн № &1", buf_gds-grp.node-code).
            end.
          end.
          else do:
            assign
            v-full-name = substitute("_НЕИЗВЕСТНАЯ Группа с вн № &1", buf_goods.grp-code).
             if v-write-err then do:
               run cb_write-report-error in p-parent-handle ( input p-rebh
                                                             ,input p-report-id
                                                             ,input ?
                                                             ,input '2':U
                                                             ,input substitute("Не найдена группа с ВН № &1 для товара с кодом &2"
                                                                              , buf_goods.grp-code
                                                                              , buf_goods.gds-code
                                                                              )).
             end.
          end.
          find first buf_gds-dyn-salt where
                    buf_gds-dyn-salt.obj-type = buf_temp-obj.obj-type
               and  buf_gds-dyn-salt.obj-code = buf_temp-obj.obj-code
               and  buf_gds-dyn-salt.shift-date = buf_temp-obj.shift-date
               and  buf_gds-dyn-salt.shift-num = buf_temp-obj.shift-num
               and  buf_gds-dyn-salt.gds-code = buf_goods.gds-code
               no-error.
          if not available buf_gds-dyn-salt then do:
            create buf_gds-dyn-salt.
            assign
            buf_gds-dyn-salt.obj-type = buf_temp-obj.obj-type
            buf_gds-dyn-salt.obj-code = buf_temp-obj.obj-code
            buf_gds-dyn-salt.shift-date = buf_temp-obj.shift-date
            buf_gds-dyn-salt.shift-num = buf_temp-obj.shift-num
            buf_gds-dyn-salt.gds-code = buf_goods.gds-code
            buf_gds-dyn-salt.node-code = buf_goods.grp-code
            buf_gds-dyn-salt.unit-base = buf_goods.unit-base
            buf_gds-dyn-salt.gds-name = buf_goods.gds-name
            .
            assign
            v-is-petrol = no
            v-is-pieces = no
            .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
            assign
            buf_gds-dyn-salt.is-petrol = (v-is-petrol and not v-is-pieces)
            .
          end.
          assign
          buf_gds-dyn-salt.fact-qnty = buf_gds-dyn-salt.fact-qnty + buf_chk-gds.doc-qnty
          buf_gds-dyn-salt.fact-sum = buf_gds-dyn-salt.fact-sum +
                                     buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_gds-dyn-salt.
          find first buf_grp-dyn-salt where
                      buf_grp-dyn-salt.obj-type = buf_temp-obj.obj-type
                and  buf_grp-dyn-salt.obj-code = buf_temp-obj.obj-code
                and  buf_grp-dyn-salt.shift-date = buf_temp-obj.shift-date
                and  buf_grp-dyn-salt.shift-num = buf_temp-obj.shift-num
                and  buf_grp-dyn-salt.node-code = buf_goods.grp-code
                no-error.
          if not available buf_grp-dyn-salt then do:
            create buf_grp-dyn-salt.
            assign
            buf_grp-dyn-salt.obj-type = buf_temp-obj.obj-type
            buf_grp-dyn-salt.obj-code = buf_temp-obj.obj-code
            buf_grp-dyn-salt.shift-date = buf_temp-obj.shift-date
            buf_grp-dyn-salt.shift-num = buf_temp-obj.shift-num
            buf_grp-dyn-salt.node-code = buf_goods.grp-code
            buf_grp-dyn-salt.full-name = v-full-name
            .
          end.
          assign
          buf_grp-dyn-salt.fact-qnty = buf_grp-dyn-salt.fact-qnty + buf_chk-gds.doc-qnty
          buf_grp-dyn-salt.fact-sum = buf_grp-dyn-salt.fact-sum +
                                    buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_grp-dyn-salt.
        end.
      end.
    end.
  end.
  if v-current-cash-num > -1 then do:
    find first buf_cd-dyn-salt where
              buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
          and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
          and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
          and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
          and buf_cd-dyn-salt.cash-num = v-current-cash-num no-error.
    assign
    buf_cd-dyn-salt.end-date = v-fix-end-date
    buf_cd-dyn-salt.end-time = v-fix-end-time
    buf_cd-dyn-salt.start-date = v-fix-start-date
    buf_cd-dyn-salt.start-time = v-fix-start-time
    .
  end.
  find first buf_obj-dyn-salt where
            buf_obj-dyn-salt.obj-type = buf_temp-obj.obj-type
        and buf_obj-dyn-salt.obj-code = buf_temp-obj.obj-code
        and buf_obj-dyn-salt.shift-date = buf_temp-obj.shift-date
        and buf_obj-dyn-salt.shift-num = buf_temp-obj.shift-num no-error.
  if not available buf_obj-dyn-salt then do:
    create buf_obj-dyn-salt.
  end.
  buffer-copy buf_temp-obj
  to buf_obj-dyn-salt
  assign
  buf_obj-dyn-salt.report-num = buf_obj-dyn-salt.report-num + 1
  buf_obj-dyn-salt.current-datetime = v-current-datetime
  buf_obj-dyn-salt.obj-address = v-obj-address
  buf_obj-dyn-salt.obj-phone = v-obj-phone
  .
  release buf_obj-dyn-salt.
  run rep-clb_save-rep-xml in this-procedure (
                             input parparentproc
                            ,input p-parent-handle
                            ,input p-log-handle
                            ,input p-cont-handle
                            ,input p-report-id
                            ,input buf_temp-obj.field-name_
                            ,input buf_temp-obj.part-num-list
                            ,input buf_temp-obj.db-num-list
                            ,input buf_temp-obj.int64-id-list
                            ,input (?)
                            ,input substitute("ДИНАМИКА ПРОДАЖ НА АЗС &1&2, смена &3 №&4 П.&5"
                                          , buf_temp-obj.obj-type
                                          , buf_temp-obj.obj-code
                                          , string(buf_temp-obj.shift-date, "99/99/9999")
                                          , buf_temp-obj.shift-name
                                          , buf_temp-obj.shift-num)
                           ,input no
                           ,input "1251"
                           ,input v_obj-dataseth
                            ) no-error.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '3':U
                                                    ,input substitute("Ошибка при сохранении в БД среза по &1&2 смена от &3 П.&4&5&6&5&7"
                                                                      , buf_temp-obj.obj-type
                                                                      , buf_temp-obj.obj-code
                                                                      , string(buf_temp-obj.shift-date)
                                                                      , buf_temp-obj.shift-num
                                                                      , chr(10)
                                                                      , error-status:get-message(1)
                                                                      , return-value
                                                                      )).
    end.
  end.
  glog = p-dataseth:copy-dataset (
                          v_obj-dataseth
                        , no
                        , yes
                        , yes
                        ) no-error.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '3':U
                                                    ,input substitute("Ошибка при сохранении в отчет среза по &1&2 смена от &3 П.&4&5&6&5&7&5"
                                                                     , buf_temp-obj.obj-type
                                                                     , buf_temp-obj.obj-code
                                                                     , string(buf_temp-obj.shift-date)
                                                                     , buf_temp-obj.shift-num
                                                                     , chr(10)
                                                                     , error-status:get-message(1)
                                                                     , return-value
                                                                     )).
    end.
  end.
end.
for each buf_temp-xml-tables:
  case buf_temp-xml-tables.tbl-name:
    when "grp-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer grp-dyn-salt:handle
                                                    , no
                                                    , yes
                                                    , yes
                                                    ) no-error.
    end.
    when "gds-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer gds-dyn-salt:handle
                                                    , yes
                                                    , yes
                                                    , yes
                                                    ) no-error.
    end.
    when "cd-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer cd-dyn-salt:handle
                                                    , no
                                                    , yes
                                                    , yes
                                                    ) no-error.
    end.
    when "obj-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer obj-dyn-salt:handle
                                                    , no
                                                    , yes
                                                    , yes
                                                    ) no-error.
    end.
end case.
end.
delete object v_obj-dataseth
