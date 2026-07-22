block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getustat.p $
$Archive: gbl/getustat.p $

Получить статистику работы пользователя с базой данных

Автор: Перваков Михаил Сергеевич
Дата создания: 07/21/05
Author: Mikhail Pervakov
Creation date: 07/21/05

*/

define input  parameter p-userio-id        as integer   no-undo .
define output parameter p-sys-time-mjd     as decimal   no-undo .
define output parameter p-userio-ai-read   as decimal   no-undo .
define output parameter p-userio-ai-write  as decimal   no-undo .
define output parameter p-userio-bi-read   as decimal   no-undo .
define output parameter p-userio-bi-write  as decimal   no-undo .
define output parameter p-userio-db-access as decimal   no-undo .
define output parameter p-userio-db-read   as decimal   no-undo .
define output parameter p-userio-db-write  as decimal   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getustat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getustat.p $":U .
define variable vss-description as character no-undo init "Получить статистику работы пользователя с базой данных".
{ cmp/vssrevis.i }
{ gbl/sys-time.i }

do
on error undo, return error return-value
:
  assign
    p-sys-time-mjd = sys-time_get-mjd-func()
  .

  find first ub._userio no-lock
    where ub._userio._userio-id = p-userio-id
    .
  assign
    p-userio-ai-read   = ub._userio._userio-airead
    p-userio-ai-write  = ub._userio._userio-aiwrite
    p-userio-bi-read   = ub._userio._userio-biread
    p-userio-bi-write  = ub._userio._userio-biwrite
    p-userio-db-access = ub._userio._userio-dbaccess
    p-userio-db-read   = ub._userio._userio-dbread
    p-userio-db-write  = ub._userio._userio-dbwrite
  .
end.