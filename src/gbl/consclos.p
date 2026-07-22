block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: consclos.p $
$Archive: gbl/consclos.p $

Закрыть консольное окно приложени

Автор: Перваков Михаил Сергеевич
Дата создания: 02/08/06
Author: Mikhail Pervakov
Creation date: 02/08/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: consclos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/consclos.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define variable v-result                as integer   no-undo .

do
on error undo, return error return-value
:
  run FreeConsole
    (output v-result
    ) .

end.

PROCEDURE FreeConsole EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .