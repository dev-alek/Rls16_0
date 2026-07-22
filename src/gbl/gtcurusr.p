block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gtcurusr.p $
$Archive: gbl/gtcurusr.p $

Получить текущего пользовател

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/14/05

*/


define input parameter  parparentproc  as widget-handle no-undo .
define output parameter p-cntxt-userid as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gtcurusr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/gtcurusr.p $":U .
define variable vss-description as character no-undo init "Получить текущий объект и фирму".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  assign
    p-cntxt-userid = v-cntxt-userid
  .
end.