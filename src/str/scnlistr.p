block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scnlistr.p $
$Archive: str/scnlistr.p $

Формирование списка товаров с количествами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scnlistr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/scnlistr.p $":U .
define variable vss-description as character no-undo initial "Формирование списка товаров с количествами".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/gds-list.i gds-list def " new shared " }
&undefine gds-list_i_def
{ cmp/gds-list.i scn-list def " new shared " }
{ cmp/goa-list.i goa-list def " new shared " }

do
on error undo, return error return-value
:
  run str/scn-list.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code).

end.