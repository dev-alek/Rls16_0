block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-paytop.p $
$Archive: rep/g-paytop.p $

Топливные платежи по видам топлива

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-paytop.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-paytop.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define new shared variable method as character no-undo.
method = "pay-code":U.

{ rep/g-toppay.i }