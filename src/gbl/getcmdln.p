block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getcmdln.p $
$Archive: gbl/getcmdln.p $

Определение командной строки запуска Progress

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define output parameter chrCommandLine AS CHARACTER NO-UNDO FORMAT "X(128)".

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: getcmdln.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/getcmdln.p $":U .
def var vss-description as character no-undo init "Определение командной строки запуска Progress".
{ cmp/vssrevis.i }

PROCEDURE GetCommandLineA EXTERNAL "KERNEL32.DLL"
:
  DEFINE RETURN PARAMETER ptrToString AS MEMPTR.
END PROCEDURE.

do
on error undo, return error return-value
:
  DEFINE VARIABLE ptrToString    AS MEMPTR    NO-UNDO .

  RUN GetCommandLineA (OUTPUT ptrToString).
  ASSIGN
    chrCommandLine = GET-STRING(ptrToString,1)
  .
end.