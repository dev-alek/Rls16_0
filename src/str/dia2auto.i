/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Переопределение процедур окна automain.w на процедуры окна diallog.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/08
Author: Bakhtadze Natalya
Creation date: 10/12/08

необходимо для того чтобы одни и те же процедуры корректно вызывались как из окна автоматического запуска по расписанию так и
из окна diallog.w

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure write-to-screen :
define input param p-str as character no-undo .
run write-log-and-file{1} in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.

procedure write-to-log :
define input param p-str as character no-undo .
run write-log-and-file{1} in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.

procedure write-to-log-notime :
define input param p-str as character no-undo .
run write-log-and-file{1} in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.


/* $Workfile$ e n d */