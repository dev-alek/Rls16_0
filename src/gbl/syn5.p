block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: syn5.p $
$Archive: gbl/syn5.p $

Запись в файл команды на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/28/06
Author: Bakhtadze Natalya
Creation date: 03/28/06

ожидание выполнения определенное время, возвращение кода возврата, запивываемого вызываемой программой в err файл

*/

/*командная строка*/
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
/*файл в котором надо искать результат*/
define input parameter err-file as character no-undo .

/*параметры которые добавляются к основной стоке*/
define input parameter p-bat-file as character no-undo .

/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.
/*результат команды возвращенный вызванной программой через файл*/
DEFINE OUTPUT  PARAMETER Result AS CHARACTER NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: syn5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/syn5.p $":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }

define variable result-line as character no-undo .

do
on error undo, return error
:
  /* создается временный командный файл для выполнения команды */

  run waitfram-show in this-procedure ( mess ).
  Result = "".
  OS-DELETE value(err-file).
  output to value(p-bat-file).
  PUT  UNFORMATTED cmd SKIP.
  output close.

  run waitfram-show in this-procedure ( mess ).

  /* время ожидания в секундах */
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .

  /* запуск внешней команды */
  /* в цикле ждем появляения файла ошибок в течение 5 минут */
  REPEAT WHILE v-time-count < 80 :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .

    assign
      FILE-INFO :FILE-NAME = err-file
    .
    IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
      input from value(err-file).
      repeat:
        import unformatted result-line no-error.
        if result-line <> '':U then
        result = result + (if result = '':u then '':U else {&new-line}) + result-line.
      end.
      input close.
      assign
        v-err-file-found = true
      .
      leave .
    end.
  END.

  run waitfram-hide in this-procedure .

  if v-err-file-found <> true then do:
    message vss-workfile vss-revision vss-description skip
            "Не найден файл с результатом выполнения задания " SKIP
            cmd
            view-as alert-box ERROR.
    RESULT = "error".
    OS-DELETE value(p-bat-file).
    return error.
  end.

  OS-DELETE value(err-file).
  OS-DELETE value(p-bat-file).


end.