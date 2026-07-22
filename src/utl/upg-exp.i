/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура эксопрта некой таблицы в текстовый файл для дальнейшего засасывания в ходе upgrade

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/31/07
Author: Bakhtadze Natalya
Creation date: 01/31/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if {1} = "def":U &then /* просто определение */
procedure upg-exp :
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
          v-fh = p-tbl-handle:buffer-field(v-ind)
      .
      if v-fh:data-type = {&abl-datatype-clob}
      or v-fh:data-type = {&abl-datatype-blob}
      then do:
         assign
         v-str = ?.
      end.
      else do:
         assign
          v-str = replace( v-fh:buffer-value, '"':U, '""':U )
        .
        if v-fh:data-type = {&abl-datatype-character}
        and  v-fh:buffer-value = {&question-mark}
        then do:
          assign
          v-str = substitute("'&1'", v-str).
        end.
        if        p-tbl-handle:table            eq "tt_thbj-attr"
             and  p-tbl-handle::upper-prop-code eq "gismt"
             and  v-fh:name                     eq "property-value-character"
             and (    p-tbl-handle::prop-code eq "oflinepswd"
                   or p-tbl-handle::prop-code eq "proxypswd"
                   or p-tbl-handle::prop-code eq "MaxApiToken")
          then 
             v-str = fill("*",length(v-str)).
      end.

      /* replace( replace( v-fh:buffer-value, '"':U, '""':U ), '~~':U, '~~~~':U ) */

      put stream ddl unformatted substitute( '"<&1>" "&2" ':U, v-fh:name, v-str ).
    end.
    put stream ddl unformatted skip.
  end.
end procedure. /* upg-exp */
&elseif {1} = "open":U &then /* открытие потока для экспорта */
  output stream ddl to value( {2} ) {3}.
  if p-mode <> "full" then do:
    export stream ddl substitute( "***&1***", {4}) .
  end.
&elseif {1} = "exp-tbl":U &then /* экспорт записи таблицы */
  if  p-mode = "full" then do:
    export stream ddl substitute( "&1&2&3&2&4", {2}, {&delim-nws}, {4}, {5} ) .
  end.
  run upg-exp in this-procedure
    ( input {3}
    ) .
&elseif {1} = "exp-cmd":U &then /* экспорт команды */
  export stream ddl substitute( "command&2&1&2&3&2&4", {2}, {&delim-nws}, {3}, {4} ) .
&elseif {1} = "close":U &then /* окончание пакета и закрытие потока для экспорта */
  /* запись о конце пакета: для контроля передачи */
  export stream ddl {&nwspck-end} .
  output stream ddl close.
&elseif {1} = "close-no-end-pck":U &then /* окончание пакета и закрытие потока для экспорта */
  output stream ddl close.
&elseif {1} = "transfer-replace":U &then /* перенос записи из другого такого же файла с заменой номер записи */
  define variable v-entry{&vssseq} as character no-undo .
  v-entry{&vssseq} = {2}.
  entry(num-entries(v-entry{&vssseq}, {&delim-nws}), v-entry{&vssseq}, {&delim-nws}) = string({3}) + {&double-quote}.
  put stream ddl unformatted v-entry{&vssseq} skip.
&elseif {1} = "transfer":U &then /* перенос записи из другого такого же файла без замены номера записи */
  put stream ddl unformatted {2} skip.
&endif





/* $Workfile$ e n d */