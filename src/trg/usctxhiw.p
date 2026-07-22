block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы user-context-history

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/30/06

*/

trigger procedure for write of ubflt.user-context-history old buffer old-user-context-history .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-login".
{ cmp/vssrevis.i }

main-block:
do transaction
on error   undo main-block, return error substitute('userlgnw.p error main-block,&1', return-value )
on end-key undo main-block, return error substitute('userlgnw.p end-key main-block,&1', return-value )
:

  /* таблица не ходит по новостям */

end.