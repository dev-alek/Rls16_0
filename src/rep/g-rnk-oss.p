block-level on error undo, throw.
/*

$Revision: 3cf06c882ecc, 131, rls $
$Author: DSolomko $
$Date: Thu Feb 13 13:48:38 2014 +0400 $
$Workfile: g-rnk-oss.p $
$Archive: rep/g-rnk-oss.p $



Автор: Соломко Дмитрий Владимирович
Дата создания: 18/12/13
Author: Alexey Demin
Creation date: 18/12/13

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 3cf06c882ecc, 131, rls $":U .
define variable vss-author      as character no-undo init "$Author: DSolomko $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 13 13:48:38 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-rnk-oss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-rnk-oss.p $":U .
define variable vss-description as character no-undo init "Сверка транзакций ОСС (Кубаньнефтепродукт)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

do
on error undo, return error
:

assign
  my-handle = parparentproc
.

run rep/d-report.w
    ( input parparentproc
    , input "rep/r-rnk-oss.p"
    , input vss-description
    , input 4
    , input "":U
    , input "*"
    , input ""
    , input ""
    , input "all":U
    , input yes ).

end.