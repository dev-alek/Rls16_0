block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scnblstr.p $
$Archive: str/scnblstr.p $

Формирование списка бар-кодов и ДопБк с количествами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/15/06
Author: Bakhtadze Natalya
Creation date: 06/15/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scnblstr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/scnblstr.p $":U .
define variable vss-description as character no-undo initial "Формирование списка бар-кодов и ДопБк с количествами".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/bb-list.i scnblist def " new shared " }

run str/scnblist.w (
                   input parparentproc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,input ''
                  ).