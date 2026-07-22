block-level on error undo, throw.
/*

$Revision: 842df30dc91c, 1422, test $
$Author: EShklyar $
$Date: Пт июн 29 17:59:55 2018 +0300 $
$Workfile: g-alcmarks.p $
$Archive: rep/g-alcmarks.p $

Утилита проверки целостности свободной зоны марок

Автор: Шкляр Елена
Дата создания: 07/30/08
Author: Shklyar Elena
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 842df30dc91c, 1422, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 29 17:59:55 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alcmarks.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alcmarks.p $":U .
define variable vss-description as character no-undo init "Утилита проверки целостности свободной зоны марок".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'utl/alcmarks.p'
    , input "Утилита проверки целостности свободной зоны марок":U
    , input 0 
    , input "{&g-all},{&g-grp},{&g-choice},{&g-one}":U
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input ""
    , input yes
    ).