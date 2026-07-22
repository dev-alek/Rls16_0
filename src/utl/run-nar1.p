block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-nar1.p $
$Archive: utl/run-nar1.p $

Запуск переименования артикула и(или) производителя с проверкой прав.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define input parameter parParentProc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-nar1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/run-nar1.p $":U .
define variable vss-description as character no-undo init "процедура запуска переименования артикула и(или) производителя с проверкой прав".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error
:
  define variable v-log as logical no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ren-art_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
  if v-log = false then do:
    return no-apply.
  end.

  run utl/new-art.w ( input parParentProc
                 ,input ?
                 ,input ?
                 ,input ?
                ).

end.

return.

/* $Workfile: run-nar1.p $ end */