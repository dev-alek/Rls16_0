/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка строки из пакета СПН

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/24/07
Author: Dmitry Ukhanov
Creation date: 07/24/07

ВНИМАНИЕ!!! ЭТОТ ФАЙЛ ДЛЯ ИСПОЛЬЗОВАНИЯ ТОЛЬКО В LOAD-REC.P !!!

*/

run nws-imps in p-imp-handle
  ( input-output counter
   ,output       {1}
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message(1) ) .
end.