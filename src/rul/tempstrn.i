/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для набрасывания данных вместо вывода в файл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/27/06
Author: Bakhtadze Natalya
Creation date: 10/27/06

*/

&if defined(tempstrn_i) = 0 &then
&glob tempstrn_i

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-string no-undo
field v-string as character
field string-num as integer
index pi is unique primary string-num.

procedure temp-string_clear :

  define buffer buf_temp-string for temp-string .

  do
  on error undo, return error return-value
  :
    for each buf_temp-string
    on error undo, return error
    :
      delete buf_temp-string.
    end.
  end.

end procedure. /* temp-string_clear */


procedure temp-string_write :

  define input  parameter p-v-string    as character no-undo .

  define variable v-string-num as integer no-undo .


  define buffer buf_temp-string for temp-string .

  do
  on error undo, return error return-value
  :
    find last buf_temp-string no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
      buf_temp-string.string-num     = 1
      buf_temp-string.v-string       = p-v-string
      .
    end.
    else do:
      v-string-num = buf_temp-string.string-num.
      create buf_temp-string .
      assign
      buf_temp-string.string-num = v-string-num + 1
      buf_temp-string.v-string = p-v-string
      .
    end.
  end.

end procedure. /* temp-string_write */


procedure temp-string_read :

  define input  parameter p-string-num    as integer   no-undo .
  define output parameter p-v-string      as character no-undo .

  define buffer buf_temp-string for temp-string .

  do
  on error undo, return error return-value
  :
    find first buf_temp-string
      where buf_temp-string.string-num     = p-string-num
      no-error .
    if available buf_temp-string then do:
      assign
        p-v-string = buf_temp-string.v-string
      .
    end.
    else do:
      assign
        p-v-string = '':U
      .
    end.
  end.

end procedure. /* temp-string_read */

procedure temp-string_append :

  define input  parameter p-string-num  as integer   no-undo .
  define input  parameter p-v-string    as character no-undo .
  define input  parameter p-append-char as character no-undo .

  define buffer buf_temp-string for temp-string .

  do
  on error undo, return error return-value
  :
    find first buf_temp-string
         where buf_temp-string.string-num = p-string-num
      no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
        buf_temp-string.string-num  = p-string-num
        buf_temp-string.v-string    = p-v-string
      .
    end.
    else do:
        assign
        buf_temp-string.v-string = buf_temp-string.v-string + p-append-char + p-v-string
        .
    end.
  end.

end procedure. /* temp-string_write */

procedure temp-string_get-last-num:
define output parameter p-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
find last buf_temp-string no-error.
if available buf_temp-string then do:
  p-string-num = buf_temp-string.string-num.
end.
end procedure.

procedure temp-string_delete-range:
define input parameter p-first-string-num  as integer   no-undo .
define input parameter p-last-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
for each buf_temp-string where
        buf_temp-string.string-num >= p-first-string-num
    and buf_temp-string.string-num <= p-last-string-num:
  delete buf_temp-string.
end.

end procedure.

&endif