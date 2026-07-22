block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-docdl.p $
$Archive: gbl/rt-docdl.p $

Удаление дополнительной информации по документу

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/29/05

*/

define input  parameter p-unique-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-docdl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-docdl.p $":U .
define variable vss-description as character no-undo init "Удаление дополнительной информации по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:
  do transaction
  on error undo, return error return-value
  :
    for each buf_batchprocess exclusive-lock
      where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
        and buf_batchprocess.bp_status   = {&btpr-normal}
        and buf_batchprocess.charkey_one = p-unique-doc-code
    on error undo, return error return-value
    :
      delete buf_batchprocess .
    end.

    for each buf_batchprocess exclusive-lock
      where buf_batchprocess.bp_type     = {&btpr-type-rt-doc}
        and buf_batchprocess.bp_status   = {&btpr-normal}
        and buf_batchprocess.charkey_one = p-unique-doc-code
    on error undo, return error return-value
    :
      delete buf_batchprocess .
    end.
  end.
end.