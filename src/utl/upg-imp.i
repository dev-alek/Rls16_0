/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура импорта в процессе upgrade

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/31/07
Author: Bakhtadze Natalya
Creation date: 01/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure upg-imp :
  define input  parameter p-buf-handle as handle    no-undo .


  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :
    define variable v-imp-str    as character extent 1000 no-undo .
    define variable v-num-fields as integer   no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-fld-name   as character no-undo .
    define variable v-fld-value  as character no-undo .
    define variable v-fh         as handle    no-undo .

    if not p-buf-handle:available then do:
      return error substitute( "(upg-imp) &1&2Buffer таблицы &3 еще не создан!"
                                ,vss-include-info{&vssseq}
                                ,{&new-line}
                                ,p-buf-handle:name
                              ).
    end.

    import stream imp-stream v-imp-str.

    if v-imp-str[1] <> "<num-fields>" then do:
      return error substitute( "(upg-imp) &1&2Неверный формат строки для импорта записи&2Строка должна начинаниться с <num-fields> а начинается с &3!"
                                ,vss-include-info{&vssseq}
                                ,{&new-line}
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
                                    ,vss-include-info{&vssseq}
                                    ,{&new-line}
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

end procedure. /* upg-imp */

procedure proc-load-standart :

  define input parameter p-tbl-name   as character no-undo .
  define input parameter p-uniq-gate-rec as character no-undo .
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.

  do
  on error  undo, return error substitute( "&1 (proc-load-standart). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (proc-load-standart). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (proc-load-standart). endkey", vss-include-info{&vssseq} )
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
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Есть привязанные записи, а обработка идет для одной", vss-include-info{&vssseq}, p-tbl-name, {&new-line} ).
    end.

    assign
      v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    /* создаем временную таблицу */
    create temp-table tth.

    assign
      tt-name = "wt-" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (1)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (2)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      bh_tt = tth:default-buffer-handle
    .

    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-include-info{&vssseq} ).
    end.

    /* считаем во временную таблицу запись из пакета */
    run upg-imp in p-imp-handle
      (
       input bh_tt
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.

   /* проверим нет ли такой записи в БД */

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
      return error substitute( "&1 (proc-load-standart). Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1 (proc-load-standart). Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
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
        return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-include-info{&vssseq}, p-tbl-name ).
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
                                            ,{&new-line}
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
        return error substitute( "&1 (proc-load-standart). BUFFER-COPY не прошел для таблицы &2 (&3)", vss-include-info{&vssseq}, p-tbl-name , error-status:get-message(1) ).
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
                                            ,{&new-line}
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
      return error substitute( "&1 (proc-load-standart). buffer-release не прошел для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при очистке временной таблицы &2", vss-include-info{&vssseq}, tt-name ) .
    end.

    delete object bh_tbl-name .
    delete object tth .

    assign
      fh_tbl-name  = ?
      fh_tt        = ?
      bh_tt        = ?
    .

  end.

end procedure. /* proc-load-standart */

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
  on error  undo, return error substitute( "&1 (proc-load-command). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (proc-load-command). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (proc-load-command). endkey", vss-include-info{&vssseq} )
  :
    case entry(1,rec-full,{&delim-nws}):
      when "command" then do:
        case entry(2,rec-full,{&delim-nws}):
          when "delete":U then do:
            assign
              v-key-rec = entry( 3, rec-full, {&delim-nws} )
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
                                            ,{&new-line}
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
                                                ,{&new-line}
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

end procedure. /* proc-load-command */

/* $Workfile$ e n d */