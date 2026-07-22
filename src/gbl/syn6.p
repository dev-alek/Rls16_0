block-level on error undo, throw.
/*

$Revision: 2cbe4bce4854, 621, rls $
$Author: PGridchina $
$Date: Wed May 11 17:10:38 2016 +0400 $
$Workfile: syn6.p $
$Archive: gbl/syn6.p $

запуск на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

ожидание выполнени
возвращение строки возврата, запивываемого вызываемой программой в err файл
если файл пустой все хорошо

*/

/*командная строка*/
DEFINE INPUT PARAMETER Cmd AS CHARACTER No-UNDO.
/*файл в котором надо искать результат*/
define input parameter err-file as character no-undo .
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHARACTER NO-UNDO.
/*результат команды возвращенный вызванной программой через файл*/
DEFINE OUTPUT  PARAMETER Result AS CHARACTER NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: 2cbe4bce4854, 621, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed May 11 17:10:38 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: syn6.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/syn6.p $":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }


do
on error undo, return error
:
  /* создается временный командный файл для выполнения команды */
  define variable bat-file as char no-undo.
  run gbl/_tmpfile.p ("", "bat", output bat-file) .

  run waitfram-show in this-procedure ( mess ).
  Result = ''.
  OS-DELETE value(err-file).

  output to value(bat-file).
  PUT  UNFORMATTED cmd SKIP.
  output close.

  run waitfram-show in this-procedure ( mess ).
  OS-COMMAND silent value(bat-file).

  /* время ожидания в секундах */
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .

  /* запуск внешней команды */
  /* в цикле ждем появляения файла ошибок в течение 0.5 минут */

  REPEAT WHILE v-time-count < 30 :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .

    assign
      FILE-INFO :FILE-NAME = err-file
    .

    IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
      if FILE-INFO:file-size = 0 then do:
        assign
          v-err-file-found = true
        .
        leave .
      end.
      else do:
        input from value(err-file).
        import unformatted result no-error.
        input close.
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            OS-DELETE value(err-file).
            OS-DELETE value(bat-file).
            return error.
        end.
        assign
          v-err-file-found = true
        .
        leave .
      end.
    end.
  END.

  run waitfram-hide in this-procedure .

  if v-err-file-found <> true then do:
    message vss-workfile vss-revision vss-description skip
            "Не найден файл с результатом выполнения задания " SKIP
            cmd skip
            err-file
            view-as alert-box ERROR.
    RESULT = "error".
    OS-DELETE value(bat-file).
    return error.
  end.

  OS-DELETE value(err-file).
  OS-DELETE value(bat-file).


end.