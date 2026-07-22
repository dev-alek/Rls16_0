block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 0d3673848966, 2893, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:12 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-xpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-xpr.p $":U .
define variable vss-description as character no-undo init "Отсылка на кассу параметров".
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
define new shared variable base-cass as int no-undo.
define new shared variable right-curs as log no-undo.
define new shared variable curr-list as char no-undo.
define new shared variable pay-list as character no-undo.
define new shared variable nal as integer no-undo.
define new shared variable kassa-rub-code      as  integer  no-undo .
define new shared variable unq-artc as logical no-undo init no.
define new shared variable val-abbr as character no-undo.
define new shared variable val-cass as character no-undo.
define new shared variable val-shop as character no-undo.
define new shared variable pay-val as character no-undo.
define new shared variable pay-cass as character no-undo.
define new shared variable pay-shop as character no-undo.
define new shared variable nal-rub as integer no-undo.
define new shared variable abbr as character no-undo.
define new shared variable pay-nal as integer no-undo.
define new shared variable cass-card as character no-undo.
define new shared variable trade-card as character no-undo.
define new shared variable curr-card as character no-undo.
define new shared variable not-nal as integer no-undo.
define new shared variable lll as int no-undo initial 0.
define new shared variable ibmspool as character no-undo .
define new shared variable ibmgroup as logical no-undo init yes.
define new SHARED variable specgrp as character no-undo init '':U.
define new shared variable varscales-pref as character no-undo .
define new shared variable varpgscales-pref as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type0 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type0
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type0 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type0
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define new SHARED temp-table chk_doc no-undo
field doc-code as char
field chk-date as date
field chk-time as int
field chk-num as int
field g-lines as int
field p-lines as int
.
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
define new shared temp-table tt-ext-file-par no-undo like ub.ext-file-par.
procedure ext-file-par-clear-temp :
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    for each buf_tt-ext-file-par
    on error undo, return error
    :
      delete buf_tt-ext-file-par .
    end.
  end.
end procedure.
procedure ext-file-par-write-temp :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_tt-ext-file-par
      where buf_tt-ext-file-par.db-num        = p-db-num
        and buf_tt-ext-file-par.file-num      = p-file-num
        and buf_tt-ext-file-par.from-db-num   = p-from-db-num
        and buf_tt-ext-file-par.param-type    = p-value-type
        and buf_tt-ext-file-par.param-name    = p-value-name
      no-error .
    if not available buf_tt-ext-file-par then do:
      create buf_tt-ext-file-par .
      assign
        buf_tt-ext-file-par.db-num         = p-db-num
        buf_tt-ext-file-par.from-db-num    = p-from-db-num
        buf_tt-ext-file-par.file-num       = p-file-num
        buf_tt-ext-file-par.param-num      = p-param-num
        buf_tt-ext-file-par.param-type     = p-value-type
        buf_tt-ext-file-par.user-db-num    = p-db-num
              .
    end.
    CASE p-value-type:
      when 'C':U
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_tt-ext-file-par.param-name = p-value-name
        buf_tt-ext-file-par.param-value = p-value-char
        .
      end.
      when 'T':U then do:
        assign
        buf_tt-ext-file-par.param-date-name = p-value-name
        buf_tt-ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_tt-ext-file-par.param-int-name = p-value-name
        buf_tt-ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'L':U then do:
        assign
        buf_tt-ext-file-par.param-log-name = p-value-name
        buf_tt-ext-file-par.param-log-value = p-value-logical
        .
      end.
      when 'D':U then do:
        assign
        buf_tt-ext-file-par.param-decimal-name = p-value-name
        buf_tt-ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
    END CASE.
  end.
end procedure.
procedure ext-file-par-write-and-send :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define input  parameter p-send        as logical no-undo .
  define input  parameter p-list-db-num as character no-undo .
  define buffer buf_ext-file-par for ub.ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_ext-file-par
      where buf_ext-file-par.db-num         = p-db-num
        and buf_ext-file-par.from-db-num    = p-from-db-num
        and buf_ext-file-par.file-num       = p-file-num
        and buf_ext-file-par.param-num      = p-param-num
      no-error .
    if not available buf_ext-file-par then do:
      create buf_ext-file-par .
      assign
        buf_ext-file-par.db-num    = p-db-num
        buf_ext-file-par.from-db-num    = p-from-db-num
        buf_ext-file-par.file-num    = p-file-num
        buf_ext-file-par.param-num    = p-param-num
        buf_ext-file-par.param-type   = p-value-type
        buf_ext-file-par.user-db-num    = p-db-num
      .
    end.
    CASE p-value-type:
      when 'C':U
      or when ''
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_ext-file-par.param-name = p-value-name
        buf_ext-file-par.param-value = p-value-char
        .
        if p-value-type = ''
        and p-param-num = 0 then do:
          buf_ext-file-par.param-log-value = p-value-logical.
        end.
      end.
      when 'T':U then do:
        assign
        buf_ext-file-par.param-date-name = p-value-name
        buf_ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_ext-file-par.param-int-name = p-value-name
        buf_ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'D':U then do:
        assign
        buf_ext-file-par.param-decimal-name = p-value-name
        buf_ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
      when 'L':U then do:
        assign
        buf_ext-file-par.param-log-name = p-value-name
        buf_ext-file-par.param-log-value = p-value-logical
        .
      end.
    END CASE.
    if p-send then do:
      run nws/cr-route.p (
                      input 'send-tbl':U
                    , input 'ext-file-par':U
                    , input buffer buf_ext-file-par:handle
                    , input p-list-db-num) no-error.
    end.
  end.
end procedure.
define variable p-cash-desk-uniq-key-rec as character no-undo .
define variable action     as character no-undo .
define variable p-ext-file-uniq-key-rec as character no-undo .
define variable i-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable p-db-num   like ub.cash-desk.db-num no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable p-pos-type like ub.cash-desk.pos-type no-undo .
define variable p-cash-num like ub.cash-desk.cash-num no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-error-num as integer no-undo .
define variable v-reply-file-name as character no-undo .
define variable v-param-num as integer no-undo .
define variable v-log-file-uniq-key-rec as character no-undo .
define variable v-reply-file-uniq-key-rec as character no-undo .
define variable v-unc-reply-file-name as character no-undo .
define variable v-unc-log-file-name as character no-undo .
define buffer target_cash-desk for ub.cash-desk.
define buffer buf_ext-file for ub.ext-file.
define buffer buf2_ext-file for ub.ext-file.
define new shared temp-table tt-ext-file no-undo like ub.ext-file.
define new shared temp-table tt-db       no-undo like ub.db.
define temp-table rtt-ext-file no-undo like ub.ext-file.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.
define buffer buf_db for ub.db.
define buffer buf_ext-file-par for ub.ext-file-par.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure bintrn_create-file-record :
define input parameter p-path as character no-undo .
define input parameter p-file-type as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-full-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE v-md5-signature AS CHARACTER NO-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-full-path2        as character no-undo .
define buffer buf_tt-ext-file for tt-ext-file.
do
on error undo, return error
:
  run gbl/filename.p (
                  input  p-path
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error  = yes then do:
    undo, return  substitute("Ошибка при поиске файла &1:&2&3&2&4"
                              , p-path
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value ).
  end.
  assign
  v-full-path = prepare-path(v-full-path).
  v-full-path2 = prepare-path2(v-full-path).
  define variable v-unc as character no-undo .
  run gbl/get-unc.p ( input v-full-path2, output v-unc) no-error.
  if not error-status :error then do:
    assign
    v-full-path2 = v-unc.
  end.
  file-info:FILE-NAME = v-full-path.
  run gbl/md5.p (
      input  v-full-path
    ,output v-md5-signature
    ) no-error.
  if error-status:error then do:
    undo, return substitute("Ошибка при выполнении подсчета КС файла &1&2" +
                "&3&2&4"
                , v-full-path
                , chr(10)
                , error-status:get-message(1)
                , return-value ).
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_tt-ext-file.
  ASSIGN
  buf_tt-ext-file.FILE-NAME = v-full-path
  buf_tt-ext-file.FILE-NAME-exec = v-full-path2
  buf_tt-ext-file.file-num = 1
  buf_tt-ext-file.create-sys-date      = file-info:FILE-mod-DATE
  buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
  buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
  buf_tt-ext-file.update-sys-date      = v-today
  buf_tt-ext-file.update-sys-time      = STRING(v-time, "HH:MM:SS")
  buf_tt-ext-file.update-sys-time-INT  = v-time
  buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
  buf_tt-ext-file.crc-field            = v-md5-signature
  buf_tt-ext-file.file-type            = p-file-type
  .
  release buf_tt-ext-file.
  p-full-name = v-full-path.
end.
end procedure.
define stream bar.
define stream plucash.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
log-file-name = "sendxprr.txt".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure putc-xpr :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-what-send as character no-undo .
define variable v-cash-num as integer no-undo init -1.
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-override as integer no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf2_cash-desk-attr for ub.cash-desk-attr.
  do
  on error undo, return error return-value
  :
    v-what-send = buf_ext-file.file-name.
    run adm/extfsavd.p (
                  INPUT buf_ext-file.db-num
                  ,INPUT buf_ext-file.from-db-num
                  ,INPUT buf_ext-file.file-num
                  ,INPUT v-xml-file-name-path  +  "xm1"
                  ,INPUT-OUTPUT v-override) NO-ERROR.
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .
define buffer for-cash-desk for ub.cash-desk.
FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = p-db-num AND
        for-cash-desk.pos-type = p-pos-type AND
        for-cash-desk.obj-code = p-obj-code AND
        for-cash-desk.cash-on  = yes AND
        (p-cash-num = ? or
        for-cash-desk.cash-num = p-cash-num)
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ('NCR-GM':U + chr(44) +
             'IBM-XML':U + chr(44) +
             'MAGIA-XML':U + chr(44) +
             'NCR-AS@R':U
               )) > 0
  and for-cash-desk.autonomy = integer('1':U) then NEXT.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка файла параметров'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
  end.
END CASE.
  RUN putc-xpr in this-procedure
               ( buffer for-cash-desk
                ,input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input for-cash-desk.cash-os
                ,input for-cash-desk.cash-num
                ).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run bge/os_copy.p ("M", v-xml-file-name-path + "xm1", v-xml-file-name-path + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    return error.
  end.
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'get,instant'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'изменение параметров')
                  else ('Ждите - ' + '') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  true
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input action
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
        v-reply-file-name = return-value .
    end.
      v-reply-file-name = return-value .
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
END CASE.
END .
END PROCEDURE.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = p-db-num AND
         ub.cash-desk.obj-code = p-obj-code AND
         ub.cash-desk.pos-type = p-pos-type AND
        (p-cash-num = ?
        or
        ub.cash-desk.cash-num = p-cash-num)
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd21 as character no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type22 as character no-undo .
define variable v-value-date22 as date no-undo .
define variable v-value-decimal22 as decimal no-undo .
define variable v-value-integer22 as INTEGER no-undo .
define variable v-value-logical22 AS LOGICAL no-undo .
define variable v-tth22 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd21
    ,output v-value-date22
    ,output v-value-decimal22
    ,output v-value-integer22
    ,output v-value-logical22
    ,output v-param-type22
    ,INPUT-OUTPUT table-handle v-tth22
    ) no-error .
delete object v-tth22 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
if ub.cash-desk.pos-type = 'IBM-XML':U
or ub.cash-desk.pos-type = 'Autotank':U
then do:
  file-info:file-name = (out  + "undelivered").
  if file-info:FULL-PATHNAME <> ? then do:
    run str/rsndxibm.p ( input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input out  + "undelivered" ) no-error.
  end.
end.
  end.
END CASE.
    RUN for-cash-cycle in this-procedure no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
END CASE.
  END.
END.
END PROCEDURE.
assign
p-cash-desk-uniq-key-rec = entry(1, p-parameter, chr(4))
p-ext-file-uniq-key-rec    = entry(2, p-parameter, chr(4))
action     = entry(3, p-parameter, chr(4))
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
log-file-name = substitute("&1_to_&2.txt"
                           , replace(p-ext-file-uniq-key-rec, chr(3), "_")
                           , replace(p-cash-desk-uniq-key-rec, chr(3), "_")
                           ).
run gen-row-keyr in this-procedure (
                                      input  p-cash-desk-uniq-key-rec
                                     ,input  ?
                                     ,input  "ub"
                                     ,input  ?
                                     ,input  no-lock
                                     ,output v-tbl-row
                                     ,output v-tbl-name) no-error.
find first target_cash-desk no-lock where
          rowid(target_cash-desk) = v-tbl-row no-error.
if not available target_cash-desk then do:
end.
assign
p-db-num = target_cash-desk.db-num
p-obj-code = target_cash-desk.obj-code
p-pos-type = target_cash-desk.pos-type
p-cash-num = target_cash-desk.cash-num
.
if p-db-num <> g#db-num then do:
    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("!!!Нельзя отслылать на кассу ЧУЖОЙ БД &1", p-db-num)).
  return.
end.
i-obj-code = p-obj-code.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,output v-host-code
  )  .
run gen-row-keyr in this-procedure (
                                      input  p-ext-file-uniq-key-rec
                                     ,input  ?
                                     ,input  "ub"
                                     ,input  ?
                                     ,input  no-lock
                                     ,output v-tbl-row
                                     ,output v-tbl-name) no-error.
find first buf_ext-file no-lock where
          rowid(buf_ext-file) = v-tbl-row no-error.
if not available buf_ext-file then do:
    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("!!!В хранилище текущей БД отсутствует файл &1", p-ext-file-uniq-key-rec)).
  return.
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка ФАЙЛА параметров на кассу &1 &2 маг&3", p-pos-type, p-cash-num, p-obj-code)
                                          ).
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке ФАЙЛА на кассу &1 &2 маг&3"
                         , p-pos-type, p-cash-num, p-obj-code
                        )
                                        ).
  assign
  v-view-log = yes
  .
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!При отсылке файла &1 на кассу &2 маг&3 произошли ошибки!!!', p-ext-file-uniq-key-rec, p-cash-num, p-obj-code)  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action27   as character no-undo .
  define variable v-printed27       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!При отсылке файла &1 на кассу &2 маг&3 произошли ошибки!!!', p-ext-file-uniq-key-rec, p-cash-num, p-obj-code))
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action27
    ,output v-printed27
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
for each tt-db:
  delete tt-db.
end.
for each tt-ext-file:
  delete tt-ext-file.
end.
for each tt-ext-file-par:
  delete tt-ext-file-par.
end.
run bintrn_create-file-record in this-procedure ( input log-file-name
                                                 ,input p-cash-desk-uniq-key-rec
                                                 ,input 'маг':U
                                                 ,input p-obj-code
                                                 ,output v-unc-log-file-name
                                                 ) no-error.
if error-status:error then do:
  end.
find first buf_db no-lock where
        buf_db.db-num = (if g#news
                         and g#db-num > 0
                         then 0
                         else g#db-num).
create buf_tt-db.
buffer-copy buf_db to buf_tt-db.
run ext-file-par-write-temp in this-procedure (
                                              input  ?
                                              ,input  -1
                                              ,input  1
                                              ,input  1
                                              ,input  'uniq-key-rec':U
                                              ,input  p-cash-desk-uniq-key-rec
                                              ,input  p-ext-file-uniq-key-rec
                                              ,input  ?
                                              ,input  0
                                              ,input  0.0
                                              ,input  no  ) no-error.
release buf_tt-db.
run nws/sndfnwr.p ( input parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle
                  ,input ((if g#db-num > 0
                           and g#news
                           then 'save-db':U
                           else 'save-this-db':U) + chr(4) +
                          string(0) + chr(4) +
                          log-file-name + chr(4) +
                          ''   )) no-error.
for each tt-ext-file:
  delete tt-ext-file.
end.
for each tt-ext-file-par:
  delete tt-ext-file-par.
end.
run bintrn_create-file-record in this-procedure ( input v-reply-file-name
                                                 ,input p-cash-desk-uniq-key-rec
                                                 ,input 'маг':U
                                                 ,input p-obj-code
                                                 ,output v-unc-reply-file-name
                                                ) no-error.
if error-status:error then do:
  end.
run ext-file-par-write-temp in this-procedure (
                                               input  ?
                                              ,input  -1
                                              ,input  1
                                              ,input  1
                                              ,input  'uniq-key-rec':U
                                              ,input  p-cash-desk-uniq-key-rec
                                              ,input  p-ext-file-uniq-key-rec
                                              ,input  ?
                                              ,input  0
                                              ,input  0.0
                                              ,input  no  ) no-error.
run nws/sndfnwr.p ( input parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle
                  ,input ((if g#db-num > 0
                           and g#news
                           then 'save-db':U
                           else 'save-this-db':U) + chr(4) +
                          string(0) + chr(4) +
                          v-reply-file-name + chr(4) +
                          ''   )) no-error.
for each buf_rtt-ext-file :
  if buf_rtt-ext-file.file-name = v-unc-log-file-name then do:
    run gen-key-rec in this-procedure ( input 'ext-file':U
                                       ,input (buffer buf_rtt-ext-file:handle)
                                       ,output v-log-file-uniq-key-rec) no-error.
  end.
  if buf_rtt-ext-file.file-name = v-unc-reply-file-name then do:
    run gen-key-rec in this-procedure ( input 'ext-file':U
                                       ,input (buffer buf_rtt-ext-file:handle)
                                       ,output v-reply-file-uniq-key-rec) no-error.
  end.
end.
find last buf_ext-file-par no-lock where
        buf_ext-file-par.db-num = buf_ext-file.db-num
    and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
    and buf_ext-file-par.file-num = buf_ext-file.file-num no-error.
v-param-num = (if available buf_ext-file-par
                then buf_ext-file-par.param-num + 1
                else 1).
run ext-file-par-write-and-send in this-procedure (
                                                  input  buf_ext-file.db-num
                                                  ,input  buf_ext-file.from-db-num
                                                  ,input  buf_ext-file.file-num
                                                  ,input  v-param-num
                                                  ,input  'uniq-key-rec':U
                                                  ,input  p-cash-desk-uniq-key-rec
                                                  ,input  v-log-file-uniq-key-rec
                                                  ,input  ?
                                                  ,input  0
                                                  ,input  0.0
                                                  ,input  (if v-view-log then no else yes)
                                                  ,input  (if g#db-num > 0
                                                          and g#news
                                                          then yes
                                                          else no)
                                                  ,input  g#news-source-db ) no-error.
run ext-file-par-write-and-send in this-procedure (
                                                  input  buf_ext-file.db-num
                                                  ,input  buf_ext-file.from-db-num
                                                  ,input  buf_ext-file.file-num
                                                  ,input  (- v-param-num)
                                                  ,input  'uniq-key-rec':U
                                                  ,input  p-cash-desk-uniq-key-rec
                                                  ,input  v-reply-file-uniq-key-rec
                                                  ,input  ?
                                                  ,input  0
                                                  ,input  0.0
                                                  ,input  (if v-view-log then no else yes)
                                                  ,input  (if g#db-num > 0
                                                          and g#news
                                                          then yes
                                                          else no)
                                                  ,input  g#news-source-db ) no-error.
procedure cb_set-ext-file_file-num :
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.
do
on error undo, return error
:
  find first buf_tt-ext-file.
  find first buf_rtt-ext-file where
            buf_rtt-ext-file.db-num = p-db-num
        and buf_rtt-ext-file.from-db-num = p-from-db-num
        and buf_rtt-ext-file.file-num = p-file-num no-error.
  if not available buf_rtt-ext-file then do:
    create buf_rtt-ext-file.
    buffer-copy buf_tt-ext-file
    except db-num from-db-num file-num
    to buf_rtt-ext-file
    assign
    buf_rtt-ext-file.db-num = p-db-num
    buf_rtt-ext-file.from-db-num = p-from-db-num
    buf_rtt-ext-file.file-num = p-file-num
    buf_rtt-ext-file.file-type = p-cash-desk-uniq-key-rec
    buf_rtt-ext-file.obj-type = 'маг':U
    buf_rtt-ext-file.obj-code = p-obj-code
    .
    release buf_rtt-ext-file.
  end.
end.
end procedure.
