block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: synchr.p $
$Archive: gbl/synchr.p $

запуск на выполнение командной строки без экрана

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

ожидание выполнени
возвращение кода возврата, запивываемого через операц систему в err файл

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: synchr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/synchr.p $":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ gbl/waitfram.i }


/*запуск на выполнение командной строки без экрана
ожидание выполнени
возвращение кода возврата*/
/*имя исполняемого файла который должен лежать в PATH*/
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
/*параметры командной строки*/
DEFINE INPUT PARAMETER CmdOption AS CHAR No-UNDO.
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.

/*результат команды возварщенный операционной системой через файл*/
DEFINE VARIABLE  Result as character no-undo .

DEFINE VARIABLE  ofile as char no-undo.

run gbl/_tmpfile.p ("", "", output ofile) .
OS-DELETE value(ofile + ".bat").
OS-DELETE value(ofile + ".err").
output to value(ofile + ".bat").
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
run waitfram-show in this-procedure (mess).
OS-COMMAND SILENT value(ofile + ".bat").
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
run waitfram-hide in this-procedure .
OS-DELETE value(ofile + ".bat").
OS-DELETE value(ofile + ".err").
return result.