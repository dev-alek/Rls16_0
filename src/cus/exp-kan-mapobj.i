/*

$Revision: $
$Author: $
$Date: $
$Workfile$
$Archive$

Разбор текстового файла соответствия для КанРу

Автор: Кирюхин Сергей
Дата создания: 22/07/13
Author: SKiryxin
Creation date: 22/07/13

*/

define temp-table mapobj no-undo
field obj-type as character
field obj-code as integer
field kan-code as character
index pi is unique primary obj-type obj-code.

define variable map-str as character no-undo.
define variable c_obj-type as character no-undo.
define variable i_obj-code as integer no-undo.
define variable c_kan-code as character no-undo.

input from value(search('mapobj.txt')).
repeat:
  import unformatted map-str. 
  assign
  c_obj-type = entry(1, entry(1, map-str, ';'), ',')
  i_obj-code = integer(entry(2, entry(1, map-str, ';'), ','))
  c_kan-code = entry(2, map-str, ';') no-error.
  if error-status:error then do:
      message "Ошибка при чтении файла mapobj.txt" view-as alert-box error.
      return.
  end. /* if error-status:error */
  create mapobj.
  assign
  mapobj.obj-type = c_obj-type
  mapobj.obj-code = i_obj-code
  mapobj.kan-code = c_kan-code.
end.  /* repeat */
input close.