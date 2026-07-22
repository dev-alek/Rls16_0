block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: syn4.p $
$Archive: gbl/syn4.p $

запуск на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

ожидание выполнени
возвращение кода возврата, запивываемого вызываемой программой в err файл

*/

/*командная строка*/
define input  parameter cmd      as char      no-undo.
/*файл в котором надо искать результат*/
define input  parameter err-file as character no-undo .
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
define input  parameter mess     as character      no-undo.
/* время ожидания в секундах */
define input  parameter p-time   as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: syn4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/syn4.p $":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }


define variable v-time-count     as integer no-undo .
define variable v-err-file-found as logical no-undo .


do
on error undo, return error
:
  if mess <> "" then do:
    run waitfram-show in this-procedure (mess).
  end.
  os-delete value(err-file).
  os-command no-wait value('start /min ' + cmd) .
  repeat while v-time-count <= p-time :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .
    assign
      FILE-INFO :FILE-NAME = err-file
    .
    if index(file-info:file-type, "f")  > 0
    and index(file-info:file-type, "w")  > 0
    and index(file-info:file-type, "r")  > 0
    and file-info:file-size > 0
    then  do:
      assign
        v-err-file-found = true.
      leave .
    end.
  end.
  run waitfram-hide in this-procedure .
  if v-err-file-found <> true then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден файл с результатом выполнения задания " SKIP
    cmd
    view-as alert-box ERROR.
    return error .
  end.
end.
