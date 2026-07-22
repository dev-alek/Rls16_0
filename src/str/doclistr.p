block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doclistr.p $
$Archive: str/doclistr.p $

Формирование списка документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
/*текущий код фирмы - в том числе в АРМ финансы*/


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: doclistr.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/doclistr.p $":U .
def var vss-description as character no-undo init "Формирование списка чеков".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/doc-list.i doc-list def " new shared " }

run str/doc-list.w (
               input parparentproc
               ,input p-curr-host-code
               ,input p-curr-obj-type
               ,input p-curr-obj-code

               ).