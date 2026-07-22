/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка из пакета СПН данных во временную таблицу

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/27/06
Author: Dmitry Ukhanov
Creation date: 07/27/06

*/

run nws-impl in p-imp-handle
  ( input "{1}":U
   ,input (buffer {2}{1}:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message(1) ) .
end.