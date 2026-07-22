block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: vspartsr.p $
$Archive: ref/vspartsr.p $

Запуск отчета vs-parts

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/25/05
Author: Bakhtadze Natalya
Creation date: 09/25/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-from-date as date no-undo .
define input parameter p-to-date as date no-undo .
define input parameter p-gds-art as character no-undo.
define input parameter p-num-doc as character no-undo.
define input parameter p-rec   as recid no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: vspartsr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/vspartsr.p $":U .
define variable vss-description as character no-undo init "Запуск отчета vs-parts".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rep/v-suppl.i new new }

FIND first supplier WHERE recid(supplier) = p-rec NO-LOCK.

run rep/vs-parts.w (
                    input parparentproc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input p-from-date
                   ,input p-to-date
                   ,input p-gds-art
                   ,input p-num-doc) no-error .
