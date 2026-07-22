block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: actn-clr.p $
$Archive: gbl/actn-clr.p $

Отметить систему прав, как требующую инициализации

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/16/06


*/

define input  parameter p-action-head-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: actn-clr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/actn-clr.p $":U .
define variable vss-description as character no-undo init "Отметить систему прав, как требующую инициализации".
{ cmp/vssrevis.i }

define buffer buf_action-head for ub.action-head .

do
on error undo, return error return-value
:
  find first buf_action-head exclusive-lock
    where buf_action-head.action-head-code = p-action-head-code
    no-error .
  if available buf_action-head
  then do:
    assign
      buf_action-head.action-head-control-number = ""
    .
  end.
end.