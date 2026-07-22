/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Предварительные проверки

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

if parstart_date = ? or
   parend_date   = ? then do:
   message "Не верно заданы даты отчета." view-as alert-box error.
   return.
end.
if  (pardate-shift = 3 and (parstart_shift_num = ? or parstart_shift_num = 0 or parend_shift_num = ? or parend_shift_num = 0) ) or
    (pardate-shift = 4 and (parstart_shift_num = ? or parstart_shift_num = 0                                                ) )
      then do:
   message "Неверно заданы номера смен" view-as alert-box.
   return.
end.