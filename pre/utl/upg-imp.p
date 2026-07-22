block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upg-imp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/upg-imp.p $":U .
define variable vss-description as character no-undo init "Процедура импорта текстового файла в процессе upgrade".
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
define stream Imp-stream.
define variable rec-cnt       as integer   no-undo.
define variable file-pck-name as   character            no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure upg-imp :
  define input  parameter p-buf-handle as handle    no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info0 )
  :
    define variable v-imp-str    as character extent 1000 no-undo .
    define variable v-num-fields as integer   no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-fld-name   as character no-undo .
    define variable v-fld-value  as character no-undo .
    define variable v-fh         as handle    no-undo .
    if not p-buf-handle:available then do:
      return error substitute( "(upg-imp) &1&2Buffer таблицы &3 еще не создан!"
                                ,vss-include-info0
                                ,chr(10)
                                ,p-buf-handle:name
                              ).
    end.
    import stream imp-stream v-imp-str.
    if v-imp-str[1] <> "<num-fields>" then do:
      return error substitute( "(upg-imp) &1&2Неверный формат строки для импорта записи&2Строка должна начинаниться с <num-fields> а начинается с &3!"
                                ,vss-include-info0
                                ,chr(10)
                                ,v-imp-str[1]
                              ).
    end.
    assign
      v-fld-name   = "":U
      v-fld-value  = "":U
      v-num-fields = integer( v-imp-str[2] )
    .
    block_read:
    do v-ind = 3 to v-num-fields * 2 + 2 by 2
    on error undo, return error
    :
      assign
        v-fld-name  = v-imp-str[v-ind]
      .
      if v-fld-name <> "":U then do:
        assign
          v-fld-name  = substring( v-fld-name, 2, length(v-fld-name) - 2)
          v-fld-value = v-imp-str[v-ind + 1]
          v-fh = p-buf-handle:buffer-field( v-fld-name ) no-error
        .
        if error-status :error
          or v-fh = ?
        then do:
          return error substitute( "(upg-imp) &1&2Поле &3 не найдено в таблице &4&2&5"
                                    ,vss-include-info0
                                    ,chr(10)
                                    ,v-fld-name
                                    ,p-buf-handle:name
                                  ,error-status :get-message ( 1 )
                                  ).
        end.
        assign
          v-fh:buffer-value = v-fld-value
        .
      end.
      else do:
        leave block_read.
      end.
    end.
  end.
end procedure.
procedure proc-load-standart :
  define input parameter p-tbl-name   as character no-undo .
  define input parameter p-uniq-gate-rec as character no-undo .
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.
  do
  on error  undo, return error substitute( "&1 (proc-load-standart). &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (proc-load-standart). stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1 (proc-load-standart). endkey", vss-include-info0 )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_tbl-name      as handle    no-undo .
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .
    define variable fh_tt           as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-where          as character no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable v-proc-name as character no-undo .
    define variable v-add            as logical   no-undo .
    define variable compare-log     as logical   no-undo.
    if l-counter <> 0 then do:
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Есть привязанные записи, а обработка идет для одной", vss-include-info0, p-tbl-name, chr(10) ).
    end.
    assign
      v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    create temp-table tth.
    assign
      tt-name = "wt-" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (1)", vss-include-info0, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (2)", vss-include-info0, tt-name ) .
    end.
    assign
      bh_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-include-info0 ).
    end.
    run upg-imp in p-imp-handle
      (
       input bh_tt
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    create buffer bh_tbl-name for table v-full-tbl-name .
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
      return error substitute( "&1 (proc-load-standart). Таблица &2 не имеет первичного ключа в БД", vss-include-info0, p-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1 (proc-load-standart). Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info0, v-inform, p-tbl-name ).
    end.
    assign
      v-where     = "where":U
      v-word-link = "":U
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_tbl-name  = bh_tbl-name:buffer-field( v-field-name )
        fh_tt        = bh_tt:buffer-field( v-field-name )
        v-field-val  = fh_tt:buffer-value
        v-where      = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, fh_tbl-name:table, v-field-name )
      .
      if fh_tbl-name:data-type ="character":U then do:
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
      v-where = substitute( "&1 &2", v-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    bh_tbl-name:find-first( v-where, exclusive-lock ) no-error .
    if not bh_tbl-name:available then do:
      assign
        v-ok = bh_tbl-name:buffer-create no-error
      .
      if v-ok <> true then do:
        return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-include-info0, p-tbl-name ).
      end.
      assign
        compare-log = false
        v-add = yes
      .
    end.
    else do:
      assign
        compare-log = bh_tbl-name:buffer-compare( bh_tt )
      .
      if not compare-log then do:
        v-proc-name = replace(substitute("&1_&2", v-full-tbl-name, "update"), "ub.", "").
        if lookup(v-proc-name , p-parent-handle:internal-entries ) > 0 then do:
          run value(v-proc-name) in p-parent-handle ( input bh_tbl-name
                                                      ,input bh_tt) no-error .
          if error-status:error then do:
              delete object bh_tbl-name .
              delete object tth .
              undo, return error  ( substitute( "&1. Ошибка при выполнении процедуры обновления записи по &2.&3&4&3&5"
                                            ,vss-workfile
                                            ,v-where
                                            ,chr(10)
                                            ,return-value
                                            ,error-status :get-message ( error-status :num-messages )
                                          )
                              ).
          end.
        end.
      end.
    end.
    if compare-log = false then do:
      v-ok = no.
      assign
        v-ok = bh_tbl-name:buffer-copy( bh_tt ) no-error
      .
      if v-ok <> true then do:
        return error substitute( "&1 (proc-load-standart). BUFFER-COPY не прошел для таблицы &2 (&3)", vss-include-info0, p-tbl-name , error-status:get-message(1) ).
      end.
      if v-add then do:
        v-proc-name = replace(substitute("&1_&2", v-full-tbl-name, "add"), "ub.", "").
        if lookup(v-proc-name , p-parent-handle:internal-entries ) > 0 then do:
          run value(v-proc-name) in p-parent-handle (  input bh_tbl-name
                                                      ) no-error .
          if error-status:error then do:
              delete object bh_tbl-name .
              delete object tth .
              undo, return error  ( substitute( "&1. Ошибка при выполнении процедуры добавления записи по &2.&3&4&3&5"
                                            ,vss-workfile
                                            ,v-where
                                            ,chr(10)
                                            ,return-value
                                            ,error-status :get-message ( error-status :num-messages )
                                          )
                              ).
          end.
        end.
      end.
    end.
    assign
      v-ok = bh_tbl-name:buffer-release() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). buffer-release не прошел для таблицы &2", vss-include-info0, p-tbl-name ).
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при очистке временной таблицы &2", vss-include-info0, tt-name ) .
    end.
    delete object bh_tbl-name .
    delete object tth .
    assign
      fh_tbl-name  = ?
      fh_tt        = ?
      bh_tt        = ?
    .
  end.
end procedure.
procedure proc-load-command :
  define input parameter rec-full     as character no-undo .
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.
  define variable v-key-rec        as character no-undo .
  define variable v-tbl-row        as rowid     no-undo .
  define variable v-tbl-name       as character no-undo .
  define variable v-full-tbl-name as character no-undo .
  define variable v-ok as logical no-undo .
  define variable v-proc-name as character no-undo .
  define variable bh_tbl-name      as handle no-undo .
  do
  on error  undo, return error substitute( "&1 (proc-load-command). &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (proc-load-command). stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1 (proc-load-command). endkey", vss-include-info0 )
  :
    case entry(1,rec-full,chr(1)):
      when "command" then do:
        case entry(2,rec-full,chr(1)):
          when "delete":U then do:
            assign
              v-key-rec = entry( 3, rec-full, chr(1) )
            .
            run gen-row-keyr in this-procedure
              ( input  v-key-rec
              ,input ?
              ,input "ub":U
              ,input ?
              ,input share-lock
              ,output v-tbl-row
              ,output v-tbl-name
              ) no-error .
            if error-status :error then do:
              return error  ( substitute( "&1. Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                            ,vss-workfile
                                            ,v-key-rec
                                            ,chr(10)
                                            ,return-value
                                            ,error-status :get-message ( error-status :num-messages )
                                          )
                              ).
            end.
            assign
              v-full-tbl-name = substitute( "&1.&2":U, "ub", v-tbl-name )
            .
            create buffer bh_tbl-name for table v-full-tbl-name .
            bh_tbl-name:find-by-rowid(v-tbl-row, exclusive-lock ) no-error .
            if bh_tbl-name:available then do:
              v-proc-name = replace(substitute("&1_&2", v-full-tbl-name, "delete"), "ub.", "").
              if lookup(v-proc-name , p-parent-handle:internal-entries ) > 0 then do:
                run value(v-proc-name) in p-parent-handle (bh_tbl-name) no-error .
                if error-status:error then do:
                  delete object bh_tbl-name.
                  undo, return error  ( substitute( "&1. Ошибка при выполнении процедуры удаления записи по уникальному ключу &2.&3&4&3&5"
                                                ,vss-workfile
                                                ,v-key-rec
                                                ,chr(10)
                                                ,return-value
                                                ,error-status :get-message ( error-status :num-messages )
                                              )
                                  ).
                end.
              end.
              v-ok = bh_tbl-name:buffer-delete.
            end.
            else do:
            end.
            delete object bh_tbl-name.
          end.
        end case.
      end.
    end.
  end.
end procedure.
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
if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
    view-as alert-box error
  .
  return error .
end.
main_block:
do
on error  undo, return error substitute("&1. error main_block. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey main_block")
on stop   undo, return error substitute("&1. stop main_block")
:
  define buffer buf_sys-ctrl          for ub.sys-ctrl .
  define variable rec-full      as character no-undo.
  define variable rec-name      as character no-undo.
  define variable rec-num       as integer   no-undo.
  define variable v-uniq-key-rt as character no-undo .
  define variable Ok            as logical   no-undo.
  define variable v-ind         as integer   no-undo.
  define variable sub-rec-cnt   as integer   no-undo.
  define variable v-today       as date      no-undo .
  define variable v-time        as integer   no-undo .
  define variable v-str         as character no-undo .
  define variable v-temp-str    as character no-undo .
  define variable v-temp-all as character extent 1000 no-undo .
  define variable log-file-name as character no-undo init "upg-imp.txt".
  define variable v-return-value as character no-undo .
   file-pck-name = p-parameter.
  assign
    Ok = FALSE
    .
  input stream imp-stream from value( file-pck-name ).
    run write-log-and-file in p-log-handle (                           input 1                                                         , input log-file-name                                             , input 1                                                         , input substitute("Выполняется импорт  из файла &1....", file-pck-name)).
  assign
  rec-cnt = 0
  .
  beg-imp:
  repeat
  on error  undo, return error substitute("&1. error beg-imp. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey beg-imp")
  on stop   undo, return error substitute("&1. stop beg-imp")
  :
    import stream imp-stream rec-full .
    assign rec-cnt = rec-cnt + 1.
    if rec-full = ? then do:
            run write-log-and-file in p-log-handle (                           input 1                                                         , input log-file-name                                             , input 1                                                         , input substitute( "Ошибка приема записи N &1", rec-cnt )).
      undo, return error substitute( "Ошибка приема записи N &1", rec-cnt ) .
    end.
    assign
      rec-name = entry( 1, rec-full, chr(1) )
      .
    run write-counter in p-log-handle ( input substitute("Кол-во считанных записей &1", rec-cnt)).
    transaction_block_otherwise:
    do transaction
    on error  undo, return error substitute("&1. error transaction_block_otherwise &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey transaction_block_otherwise")
    on stop   undo, return error substitute("&1. stop transaction_block_otherwise")
    :
      CASE rec-name:
        when '**END OF PACKET**':U then do:
          assign
            rec-cnt = rec-cnt - 1
            OK = yes
            .
                    run write-log-and-file in p-log-handle (                           input 1                                                         , input log-file-name                                             , input 1                                                         , input substitute("Конец импорта файла &1", file-pck-name)).
          leave beg-imp.
        end.
        when 'command':U then do:
          run proc-load-command in this-procedure
                                                  (
                                                    input rec-full
                                                  ,input this-procedure
                                                  ,input sub-rec-cnt
                                                  ) no-error.
          if error-status:error then do:
            v-return-value = return-value .
                        run write-log-and-file in p-log-handle (                           input 1                                                         , input log-file-name                                             , input 1                                                         , input (v-return-value + chr(10) + "запись N" + chr(32) + string( rec-cnt ))).
            return error (v-return-value + chr(10) + "запись N" + chr(32) + string( rec-cnt )) .
          end.
        end.
        otherwise do:
          run proc-load-standart in this-procedure
              ( input rec-name
              ,input '':U
              ,input this-procedure
              ,input sub-rec-cnt
              ) no-error.
          if error-status:error then do:
             v-return-value = return-value .
                        run write-log-and-file in p-log-handle (                           input 1                                                         , input log-file-name                                             , input 1                                                         , input (v-return-value + chr(10) + "запись N" + chr(32) + string( rec-cnt ))).
            return error (v-return-value + chr(10) + "запись N" + chr(32) + string( rec-cnt ) ).
          end.
        end.
      end case.
    end.
  end.
  input stream imp-stream close.
  hide frame imp-pck.
end.
return '':U.
