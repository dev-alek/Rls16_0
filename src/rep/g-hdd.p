block-level on error undo, throw.
/*

$Revision: c188d6f80d33, 2331, rls $
$Author: druban $
$Date: Ср июн 10 21:13:32 2020 +0300 $
$Workfile: g-hdd.p $
$Archive: rep/g-hdd.p $

Отчет Результаты проверки HDD

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

Input:

Output:

*/
define input  parameter parparentproc      as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: c188d6f80d33, 2331, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:32 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-hdd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-hdd.p $":U .
define variable vss-description as character no-undo init "Отчет Результаты проверки HDD".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cmp/r-page1.i new }


do
on error undo, return error
:
{ gbl/getcntxt.i get }

run ref/report_hdd.p ( input parparentproc) no-error.

end.
