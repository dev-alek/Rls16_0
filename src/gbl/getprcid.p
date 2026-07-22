block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getprcid.p $
$Archive: gbl/getprcid.p $

Получить PID текущей сессии progress

Автор: Перваков Михаил Сергеевич
Дата создания: 03/06/06
Author: Mikhail Pervakov
Creation date: 03/06/06

*/

define output parameter p-process-id as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getprcid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getprcid.p $":U .
define variable vss-description as character no-undo init "Получить PID текущей сессии progress".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:
  run GetCurrentProcessID (output p-process-id) .
end.


PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.