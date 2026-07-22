block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-nart.p $
$Archive: utl/run-nart.p $

Запуск переименования артикула и(или) производителя.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-nart.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/run-nart.p $":U .
define variable vss-description as character no-undo init "процедура запуска переименования артикула и(или) производителя".
{ cmp/vssrevis.i }

define input parameter parParentProc as handle no-undo .

do
on error undo, return error
:
  run utl/new-art.w ( input parParentProc
                 ,input ?
                 ,input ?
                 ,input ?
                ).

end.

return.

/* $Workfile: run-nart.p $ end */