/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для записи текстовой информации в файл с подсчетом количества выведенных строк

Автор: Перваков Михаил Сергеевич
Дата создания: 10/29/02
Author: Mikhail Pervakov
Creation date: 10/29/02


*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define stream filsout .

define variable v-filwrlib-file-name     as character no-undo .
define variable v-filwrlib-num-new-lines as integer   no-undo .

procedure filwrlib_set-file-name :

  define input  parameter p-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-filwrlib-file-name = p-file-name
    .
  end.

end procedure. /* filwrlib_set-file-name */

procedure filwrlib_num-lines-clear :

  do
  on error undo, return error return-value
  :
    assign
      v-filwrlib-num-new-lines = 0
    .
  end.

end procedure. /* filwrlib_num-lines-clear */

procedure filwrlib_num-lines-add :

  define input  parameter p-num-lines as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-filwrlib-num-new-lines = v-filwrlib-num-new-lines + p-num-lines
    .
  end.

end procedure. /* filwrlib_num-lines-add */


procedure filwrlib_num-lines-get :

  define output parameter p-num-lines as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-num-lines = v-filwrlib-num-new-lines
    .
  end.

end procedure. /* filwrlib_num-lines-get */


procedure filwrlib_clear-file :

  do
  on error undo, return error return-value
  :
    run filwrlib_num-lines-clear in this-procedure .
    output stream filsout to value(v-filwrlib-file-name) .
    output stream filsout close .
  end.

end procedure. /* filwrlib_clear-file */

procedure filwrlib_append :

  define input  parameter p-line as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-line = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение строки" skip
        "p-line" p-line skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-num-new-lines as integer   no-undo .
    assign
      v-num-new-lines = num-entries(p-line, chr(10))
    .
    if v-num-new-lines > 1 then do:
      assign
        v-num-new-lines = v-num-new-lines - 1
      .
    end.
    else do:
      assign
        v-num-new-lines = 1
      .
    end.
    run filwrlib_num-lines-add in this-procedure
      (input v-num-new-lines
      ) .
    output stream filsout to value(v-filwrlib-file-name) append.
    put stream filsout unformatted p-line .
    output stream filsout close .
  end.
end procedure. /* filwrlib_append */

procedure filwrlib_append-new-line :

  define input  parameter p-line as character no-undo .

  do
  on error undo, return error return-value
  :
    run filwrlib_append in this-procedure
      (input p-line + chr(10)
      ) .
  end.

end procedure. /* filwrlib_append-new-line */

procedure filwrlib_append-line-num :

  define input  parameter p-new-line-num as integer   no-undo .

  /* добавляет необходимое количество строк */
  /* чтобы следующая строка имела номер не менее указанного */

  do
  on error undo, return error return-value
  :
    do while p-new-line-num > v-filwrlib-num-new-lines
    :
      run filwrlib_append in this-procedure
        (input fill(chr(10), min(p-new-line-num - v-filwrlib-num-new-lines, 100))
        ) .
    end.
  end.

end procedure. /* filwrlib_append-line-num */

/* $Workfile$ e n d */