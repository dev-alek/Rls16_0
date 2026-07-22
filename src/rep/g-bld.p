block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-bld.p $
$Archive: rep/g-bld.p $

Отчет о реализации блюд и товаров в рознице

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-bld.p $":U .
define variable vss-description as character no-undo init "Отчет о реализации блюд и товаров в рознице".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
input parParentProc ,
input                       'rep/r-bld.p',
input                       'Отчет о реализации блюд и товаров в рознице',
input                        2,
input                        "",
input                        "*",
input                        "",
input                        "",
input                        "all,{&Arc-stk-yes}",
input                        yes).