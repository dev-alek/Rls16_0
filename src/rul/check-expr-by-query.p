block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка правильности выражения путем подстановки его в prepare-phrase запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/20/07
Author: Bakhtadze Natalya
Creation date: 02/20/07

*/

define input parameter p-phrase as character no-undo .
define output parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка правильности выражения путем подстановки его в prepare-phrase запроса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }

define variable v-phrase as character no-undo .
define variable v-phrase2 as character no-undo .
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-temp-file as character no-undo .
define buffer buf_file for dictdb._file.
DEFINE QUERY q-file FOR buf_file SCROLLING.
define stream outstream.


do
on error undo, return error
:
  v-phrase = str-encode ( input p-phrase
                         ,input '':U
                         ,input '"').
  v-phrase = replace(p-phrase, {&double-quote}, {&single-quote}).
  do v-ii = 1 to num-entries(v-phrase, {&space-char} ) :
    assign
    v-entry = entry(v-ii, v-phrase, {&space-char}).
    if v-entry begins ({&left-brace} + {&ampersand})
    and substring(v-entry, length(v-entry), 1) = {&right-brace} then do:
      run gbl/_tmpfile.p ( input "":U  , input ".p":U, output v-temp-file ).
      output stream outstream to value( v-temp-file ).
      output stream outstream close.
      output stream outstream to value( v-temp-file ) append.
      put stream outstream unformatted "~{ cmp/str-glbl.i ~}" skip.
      put stream outstream unformatted "define output parameter p-string as character no-undo ." skip.
      put stream outstream unformatted "define variable v-date as date no-undo ." skip.
      put stream outstream unformatted "define variable v-decimal as decimal no-undo ." skip.
      put stream outstream unformatted "define variable v-integer as integer no-undo ." skip.
      put stream outstream unformatted "define variable v-logical as logical no-undo ." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-date = date(~{1~}) no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted  "p-string = {1}." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-decimal = decimal(~{1~}) no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted "  p-string = {1}." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-integer = integer({1}) no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted "  p-string = {1}." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "p-string = substitute("'&1'", ~{1~})." skip.
      output stream outstream close.
      run value(v-temp-file) ( output v-entry)  v-entry.
    end.
    assign
    v-phrase2 = v-phrase2 + (if v-phrase2 = '':u then '':u else {&space-char}) + v-entry.
  end.
  assign
  p-ok = query q-file:query-prepare( substitute(" for each buf_file where &1", v-phrase2))
  no-error.
end. /*doe*/