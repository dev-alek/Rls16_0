block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: syn2.p $
$Archive: gbl/syn2.p $

запуск на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

ожидание выполнени
возвращение кода возврата, запивываемого вызываемой программой в err файл

*/

/*командная строка*/
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
/*файл в котором надо искать результат*/
define input parameter err-file as character no-undo .
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.
/*результат команды возвращенный вызванной программой через файл*/
DEFINE OUTPUT  PARAMETER Result AS INTEGER NO-UNDO.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: syn2.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/syn2.p $":U .
def var vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }

{ gbl/waitfram.i }


do
on error undo, return error
:
  def var ofile as char no-undo.
  run waitfram-show in this-procedure (mess).
  Result = 0.
  OS-DELETE value(err-file).
  OS-COMMAND no-wait value('start /min ' + cmd) .

  /* время ожидания в секундах */
  def var v-time-count as integer no-undo .
  def var v-err-file-found as logical no-undo .

  REPEAT WHILE v-time-count < 300 :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .

    assign
      FILE-INFO :FILE-NAME = err-file
    .
    IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
      input from value(err-file).
      import result no-error.
      input close.
      if error-status:error then do:
        run waitfram-hide in this-procedure .
        OS-DELETE value(err-file).
        return error.
      end.
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
    RESULT = 1.
    return error.

  end.

  OS-DELETE value(err-file).


end.