block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-dinamo.p $
$Archive: rep/e-dinamo.p $

Динамика движения товара - запуск 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/03
Author: Bakhtadze Natalya
Creation date: 05/27/03

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-dinamo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-dinamo.p $":U .
define variable vss-description as character no-undo init "Динамика движения товара - запуск 2".
{ cmp/vssrevis.i }

{ cmp/r-page1.i }
define shared buffer buf_goods for ub.goods.

run rep/r-dinamo.w (input my-handle, buf_goods.gds-code) no-error .