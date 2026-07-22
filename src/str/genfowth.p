block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: genfowth.p $
$Archive: str/genfowth.p $

Генерация ФО по МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/22/07
Author: Polina Gridchina
Creation date: 05/22/07

*/

define temp-table tt-wth-doc  no-undo like ub.wth-doc.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-host-code    like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo    .  /* до какой даты отбирать матценности (если из общего окна) */
define input parameter p-wth-doc      as integer no-undo .  /* тип вызова процедуры генерации  = ?-за период (из общего окна) , <> ? по списку документов(из списка МЦ)  */
define input parameter p-cons         as integer no-undo .  /* если 1 - то совокупно, если - 2 ,то каждый документ в отдельное ФО */
define input parameter p-nalog        as integer no-undo .  /* если = 2, то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-wth-doc .               /* список документов мат-ценностей , по которым будем генерить (если генерим из списка МЦ) */
define input-output parameter p-res as character no-undo .  /* Для отображения ошибок или инфо */


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: genfowth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/genfowth.p $":U .
define variable vss-description as character no-undo init "Генерация ФО по МЦ".
{ cmp/vssrevis.i }
