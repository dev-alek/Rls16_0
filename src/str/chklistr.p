block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chklistr.p $
$Archive: str/chklistr.p $

Формирование списка чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/04
Author: Bakhtadze Natalya
Creation date: 03/03/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
/*текущий код фирмы - в том числе в АРМ финансы*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklistr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklistr.p $":U .
define variable vss-description as character no-undo init "Формирование списка чеков".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/chk-list.i chk-list def " new shared " }

run str/chk-list.w (
               input parparentproc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input p-curr-host-code

                ).