/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка того, что процедура должна быть запущена с параметром persistent

Автор: Перваков Михаил Сергеевич
Дата создания: 09/20/04
Author: Mikhail Pervakov
Creation date: 09/20/04

Следует использовать вместо стандартной проверки Progress для того,
чтобы получаемый *.r код не зависел от директории компиляции

*/

if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.

/* $Workfile$ e n d */