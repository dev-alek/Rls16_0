block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-otcst.p $
$Archive: cus/g-otcst.p $

Главная программа запуска отчета g-otcst.p(таможенная оборотка) из меню

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-otcst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-otcst.p $":U .
define variable vss-description as character no-undo init "Главная программа запуска отчета g-otcst.p(таможенная оборотка) из меню".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page0.i new }

run rep/d-report.w (
                 input parparentproc
                ,input "cus/r-otcst.p"
                ,input "Отчет о товарах, помещенных под таможенный режим магазина"
                ,input 2
                ,input ""
                ,input ""
                ,input ""
                ,input ""
                ,input "all,{&Arc-STK-yes}"
                ,input yes).