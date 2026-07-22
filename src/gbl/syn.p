block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: syn.p $
$Archive: gbl/syn.p $

запуск на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/05
Author: Bakhtadze Natalya
Creation date: 11/21/05

ожидание выполнени
возвращение кода возврата, запивываемого через операц систему в err файл

*/

/*имя исполняемого файла который должен лежать в PATH*/
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
/*параметры командной строки*/
DEFINE INPUT PARAMETER CmdOption AS CHAR No-UNDO.
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.
/*результат команды возварщенный операционной системой через файл*/
DEFINE OUTPUT  PARAMETER Result AS INTEGER NO-UNDO.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: syn.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/syn.p $":U .
def var vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }


def var ofile as char no-undo.
Result = 0.
run gbl/_tmpfile.p ("", "", output ofile) .
OS-DELETE value(ofile + ".bat").
OS-DELETE value(ofile + ".err").
output to value(ofile + ".bat") convert target "ibm866".
PUT  UNFORMATTED "IF NOT EXIST " + Cmd + " goto err " SKIP.
PUT  UNFORMATTED (Cmd + " " + CmdOption) SKIP.
PUT UNFORMATTED "IF ERRORLEVEL 1 goto err"  SKIP.
PUT UNFORMATTED "goto end" SKIP.
PUT UNFORMATTED ":err" SKIP.
PUT UNFORMATTED "ECHO 1 > " ofile + ".err" SKIP.
PUT UNFORMATTED "exit" SKIP.
PUT UNFORMATTED ":end" SKIP.
PUT UNFORMATTED "ECHO 0 > " ofile + ".err" SKIP.
output close.
if mess <> '':U then
run waitfram-show in this-procedure (mess).
OS-COMMAND  silent  value(ofile + ".bat").
FILE-INFO:FILE-NAME = ofile + ".err".
IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
            input  from value(ofile + ".err").
            import result no-error.
            input close.
            if error-status:error then do:
                run waitfram-hide in this-procedure .
                OS-DELETE value(ofile + ".bat").
                OS-DELETE value(ofile + ".err").
                return error.
            end.
end.
if mess <> '':U then
run waitfram-hide in this-procedure .
OS-DELETE value(ofile + ".bat").
OS-DELETE value(ofile + ".err").