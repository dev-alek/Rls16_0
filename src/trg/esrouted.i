/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тело триггера на удаление esys-route

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/08
Author: Bakhtadze Natalya
Creation date: 02/18/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_esys-route           for {1}.esys-route .
define buffer buf_esys-route-dump      for {1}.esys-route-dump .


disable triggers for load of {1}.esys-route-dump .

find first buf_esys-route no-lock
  where buf_esys-route.esr-dump-ord = {1}.esys-route.esr-dump-ord
    and not (buf_esys-route.esys-id   = {1}.esys-route.esys-id
             and
             buf_esys-route.db-num   = {1}.esys-route.db-num)
  no-error
.
if not available buf_esys-route
then do:
  for each buf_esys-route-dump
    where buf_esys-route-dump.esrd-dump-ord = {1}.esys-route.esr-dump-ord
  on error undo, return error
  :
    delete buf_esys-route-dump.
  end.
end.


/* $Workfile$ e n d */