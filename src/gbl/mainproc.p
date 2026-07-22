block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mainproc.p $
$Archive: gbl/mainproc.p $

Пустая персистентная процедура

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/12/10
Author: Bakhtadze Natalya
Creation date: 02/12/10

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mainproc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mainproc.p $":U .
define variable vss-description as character no-undo init "Пустая персистентная процедура".
{ cmp/vssrevis.i }



procedure mainproc_empty :

return.
end procedure. /* mainproc_empty */