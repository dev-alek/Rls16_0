/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет инициатора для видеонаблюдения

Автор: Морозов Александр Сергеевич
Дата создания: 06/01/17
Author: Alexandr Morozov
Creation date: 06/01/17

*/

define variable v-initiator  as character no-undo.

case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.

/* $Workfile$ e n d */