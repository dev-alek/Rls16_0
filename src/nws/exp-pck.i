/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ёкспорт строки в файл пакета

јвтор: ”ханов ƒмитрий ёрьевич
ƒата создани€: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if {1} = "def":U &then /* просто определение */
  define stream ddl.

  procedure nws-exp :
    define input  parameter p-tbl-handle as handle    no-undo .
    do
    on error  undo, return error substitute( "&1 (nws-exp). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (nws-exp). stop", vss-include-info{&vssseq} )
    on endkey undo, return error substitute( "&1 (nws-exp). endkey", vss-include-info{&vssseq} )
    :
      define variable v-num-fields as integer   no-undo .
      define variable v-ind        as integer   no-undo .
      define variable v-fh         as handle    no-undo .
      define variable v-str        as character no-undo .

      assign
        v-num-fields = p-tbl-handle:num-fields
      .
      put stream ddl unformatted substitute( '"<num-fields>" "&1" ':U, v-num-fields ).
      do v-ind = 1 to v-num-fields
      on error undo, return error substitute( "&1 (nws-exp). &2", vss-include-info{&vssseq}, error-status :get-message ( 1 ) )
      :

          assign
            v-fh = p-tbl-handle:buffer-field(v-ind).
          if v-fh:data-type = {&abl-datatype-raw} then do:
           v-str = string(v-fh:buffer-value).
          end.
          else do:
                    /* replace( replace( v-fh:buffer-value, '"':U, '""':U ), '~~':U, '~~~~':U ) */
            v-str = replace( v-fh:buffer-value, '"':U, '""':U )
          .
          end.
        if v-fh:data-type = {&abl-datatype-character}
          and  v-fh:buffer-value = {&question-mark}
        then do:
          assign
            v-str = substitute( "'&1'", v-str )
          .
        end.
        put stream ddl unformatted substitute( '"<&1>" "&2" ':U, v-fh:name, v-str ).
      end.
      put stream ddl unformatted skip.
    end.
  end procedure. /* nws-exp */
&elseif {1} = "open":U &then /* открытие потока дл€ экспорта */
  output stream ddl to value( {2} ).
&elseif {1} begins "exp-tbl":U &then /* экспорт записи таблицы */
  export stream ddl substitute( "&1&2&3&2&4&2&5&2&6&2&7&2&8&2&9", {2}, {&delim-nws}, {3}, {5}, {6}, {7}, {8}, {9}, {10}) .
  &if {1} = "exp-tbl+":U &then
    run nws-exp in this-procedure
      ( input {4}
      ) .
  &endif
&elseif {1} = "exp-cmd":U &then /* экспорт команды */
  export stream ddl substitute( "&1&2&3&2&4&2&5&2&6&2&7", {2}, {&delim-nws}, {3}, {4}, {5}, {6}, {7} ) .
&elseif {1} = "close":U &then /* окончание пакета и закрытие потока дл€ экспорта */
  /* запись о конце пакета: дл€ контрол€ передачи */
  export stream ddl {&nwspck-end} .
  output stream ddl close.
&endif

/* $Workfile$ e n d */