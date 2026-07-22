/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд копирования таблиц через buffer-copy.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/
/*
1 - таблица источник
2 - дополнительные услови
*/
for each old-{1} {2} no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-{1}.
   buffer-copy old-{1} to new-{1}.
end.
/* $Workfile$ e n d */