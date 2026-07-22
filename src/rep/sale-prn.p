block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sale-prn.p $
$Archive: rep/sale-prn.p $

Печать продажи в различных видах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/09/05
Author: Bakhtadze Natalya
Creation date: 03/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-recid as recid no-undo.
define input parameter p-quest-print as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sale-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/sale-prn.p $":U .
define variable vss-description as character no-undo init "Печать продажи в различных видах".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define buffer buf_inkas for ub.inkas.
FIND buf_inkas WHERE
    recid( buf_inkas ) = p-recid NO-LOCK.
run rep/d-sale.w ( input parparentproc
              ,input p-recid
              ,input p-quest-print

              )  .