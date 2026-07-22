/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура импорта в формате пакета СПН во временную таблицу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/31/07
Author: Bakhtadze Natalya
Creation date: 01/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define {2} temp-table temp-tables no-undo
field tbl-name as character
field buf-handle as handle
field tbl-handle as handle
index pi is unique primary
tbl-name.

define {2} temp-table temp-command no-undo
field command-name as character
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
command-name
uniq-key-rec
index icommand
command-name
tbl-name
uniq-key-rec
.

define buffer buf_temp-tables for temp-tables.
&endif

&global-define create-static-table define ~{&shared-option~} temp-table tt-~{&table-name~} no-undo like ub.~{&table-name~} . ~
find first buf_temp-tables where buf_temp-tables.tbl-name = "~{&table-name~}" no-error. ~
if not available buf_temp-tables then do: ~
  create buf_temp-tables. ~
  assign ~
  buf_temp-tables.tbl-name = "~{&table-name~}"  ~
  buf_temp-tables.buf-handle = buffer tt-~{&table-name~}:handle  ~
  buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle ~
  . ~
  release buf_temp-tables. ~
end


&if "{1}" = "proc" &then

procedure impdelta :
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
      return error substitute( "(upg-imp) &1&2Неверный формат строки для импорта записи&2Строка должна начинаться с <num-fields> а начинается с &3!"
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

procedure proc-load-tt-standart :
  define input parameter p-tbl-name   as character no-undo .
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.

  do
  on error  undo, return error substitute( "&1 (proc-load-tt-standart). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (proc-load-tt-standart). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (proc-load-tt-standart). endkey", vss-include-info{&vssseq} )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .

    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define buffer buf_temp-tables for temp-tables.

    if l-counter <> 0 then do:
      return error substitute( "&1 (proc-load-tt-standart). Ошибка обработки записи &2&3Есть привязанные записи, а обработка идет для одной", vss-include-info{&vssseq}, p-tbl-name, {&new-line} ).
    end.

    assign
      v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    find first buf_temp-tables where
              buf_temp-tables.tbl-name = p-tbl-name no-error .
    if not available buf_temp-tables then do:
      /* создаем временную таблицу */
      create temp-table tth.

      assign
        tt-name = "wt-" + p-tbl-name
        tth:undo = no
      .
      assign
        v-ok = tth:create-like( v-full-tbl-name ) no-error
      .
      if v-ok <> true then do:
        return error substitute( "&1 (proc-load-tt-standart). Ошибка при создании временной таблицы &2 (&3) (1)", vss-include-info{&vssseq}, tt-name, error-status:get-message(1)  ) .
      end.

      assign
        v-ok = tth:temp-table-prepare( tt-name ) no-error
      .
      if v-ok <> true then do:
        return error substitute( "&1 (proc-load-tt-standart). Ошибка при создании временной таблицы &2 (&3) (2)", vss-include-info{&vssseq}, tt-name, error-status:get-message(1)  ) .
      end.
      create buf_temp-tables.
      assign
      buf_temp-tables.tbl-name = p-tbl-name
      buf_temp-tables.buf-handle = tth:default-buffer-handle
      buf_temp-tables.tbl-handle = tth
      .
     end.
     assign
      bh_tt = buf_temp-tables.buf-handle
      .

      assign
        v-ok = bh_tt:buffer-create no-error
      .
      if v-ok <> true then do:
        return error substitute( "&1 (proc-load-tt-standart). Ошибка при создании буфера временной таблицы.", vss-include-info{&vssseq} ).
      end.

      /* считаем во временную таблицу запись из пакета */
      run impdelta in p-imp-handle
        (
        input bh_tt
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.

  end.

end procedure. /* proc-load-tt-standart */

procedure proc-load-tt-command :
  define input parameter rec-full     as character no-undo .
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.

  define variable v-key-rec        as character no-undo .
  define variable v-tbl-row        as rowid     no-undo .
  define variable v-tbl-name       as character no-undo .
  define variable v-full-tbl-name as character no-undo .
  define variable v-ok as logical no-undo .
  define variable bh_tbl-name      as handle no-undo .
  define buffer buf_temp-command for temp-command.


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
              find first buf_temp-command where
                        buf_temp-command.tbl-name = v-tbl-name
                    and buf_temp-command.command-name = entry(2,rec-full,{&delim-nws})
                    and buf_temp-command.uniq-key-rec = v-key-rec  no-error .
              if not available buf_temp-command then do:
                create buf_temp-command.
                assign
                buf_temp-command.tbl-name = v-tbl-name
                buf_temp-command.command-name = entry(2,rec-full,{&delim-nws})
                buf_temp-command.uniq-key-rec = v-key-rec
                no-error.
                if error-status:error then do:
                  return error substitute( "&1 (proc-load-tt-command). Ошибка при создании записи необходимости удаления.", vss-include-info{&vssseq} ).
                end.
              end.
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

&endif

/* $Workfile$ e n d */