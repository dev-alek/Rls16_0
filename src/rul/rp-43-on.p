block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка при включении профайла 43 - импорт товаров из Oracle Retail

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/23/09
Author: Bakhtadze Natalya
Creation date: 02/23/09

*/

define input  parameter parparentproc as widget-handle no-undo .
define output parameter p-ok as logical   no-undo .
define output parameter p-mess as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка при включении профайла 42 - импорт клиентов из Oracle Retail".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-last-code as integer no-undo .
define buffer buf_code-range for ub.code-range.

find first buf_code-range no-lock where
        buf_code-range.range-type = {&gbl-bc-code}
      and buf_code-range.db-num > 0 no-error.
if available buf_code-range then do:
  p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов, привязанные к УБД").
  return ''.
end.
find first buf_code-range no-lock where
        buf_code-range.range-type = {&gbl-bc-code}
      and buf_code-range.db-num < 0 no-error.
if available buf_code-range then do:
  p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов, непривязанные к БД").
  return ''.
end.

v-last-code = -1.
for each buf_code-range no-lock where
        buf_code-range.range-type = {&gbl-bc-code}
by buf_code-range.first-code:
   if v-last-code >= 0
   and buf_code-range.first-code + 1 < v-last-code  then do:
     p-mess = substitute("Нельзя включить профайл - существуют <ДЫРКИ> в последовательности диапазонов бар-кодов").
     return ''.
   end.
   if buf_code-range.stts <> 'U' then do:
     p-mess = substitute("Нельзя включить профайл - существуют диапазоны бар-кодов со статусом &1", buf_code-range.stts).
     return ''.
   end.
   assign
   v-last-code = buf_code-range.last-code
   .
end.


