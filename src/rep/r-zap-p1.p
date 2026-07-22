block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zap-p1.p $
$Archive: rep/r-zap-p1.p $

ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-zap-p1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-zap-p1.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ rep/r-zap-pr.i rubl }