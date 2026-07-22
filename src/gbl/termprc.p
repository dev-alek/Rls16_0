block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: termprc.p $
$Archive: gbl/termprc.p $

Завершить процесс

Автор: Перваков Михаил Сергеевич
Дата создания: 06/06/03
Author: Mikhail Pervakov
Creation date: 06/06/03

*/

define input parameter p-process-id as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: termprc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/termprc.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable v-process-handle as integer no-undo.
define variable v-return-value   as integer no-undo.

&GLOB PROCESS_TERMINATE 1

run OpenProcess
  (input  {&PROCESS_TERMINATE}
  ,input  0
  ,input  p-process-id
  ,output v-process-handle
  ).

if v-process-handle <> 0
then do:
   run TerminateProcess
     (input  v-process-handle
     ,input  0
     ,output v-return-value
     ).
   run CloseHandle
     (input  v-process-handle
     ,output v-return-value
     ).
end.


PROCEDURE OpenProcess EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER dwDesiredAccess AS LONG.
  DEFINE INPUT  PARAMETER bInheritHandle  AS LONG.
  DEFINE INPUT  PARAMETER dwProcessId     AS LONG.
  DEFINE RETURN PARAMETER hProcess        AS LONG.
END PROCEDURE.

PROCEDURE CloseHandle EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hObject     AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

PROCEDURE TerminateProcess EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hProcess  AS LONG.
  DEFINE INPUT  PARAMETER uExitCode AS LONG.
  DEFINE RETURN PARAMETER retval    AS LONG.
END PROCEDURE.