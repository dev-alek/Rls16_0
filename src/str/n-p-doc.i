/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кнопки в переоценки

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06


*/
ON CHOOSE OF b-next IN FRAME {&frame-name}
DO:
if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row().
  if not g#log then message "Это последний документ списка.".
end.
doc-rec = recid ({1}).
next-prev = yes.
END.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
DO:
if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row().
  if not g#log then message "Это первый документ списка.".
end.
doc-rec = recid ({1}).
next-prev = yes.
END.
