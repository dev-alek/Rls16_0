block-level on error undo, throw.
/*

$Revision: 696475c38a77, 2408, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:45 2020 +0300 $
$Workfile: g-tobacco-marks.p $
$Archive: rep/g-tobacco-marks.p $

Утилита проверки целостности свободной зоны марок

Автор: Шкляр Елена
Дата создания: 07/30/08
Author: Shklyar Elena
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 696475c38a77, 2408, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:45 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-tobacco-marks.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-tobacco-marks.p $":U .
define variable vss-description as character no-undo init "Утилита проверки целостности свободной зоны марок".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-tobacco-marks.w'
    , input "Отчёт о состоянии остатков табачной продукции":U
    , input 0 
    , input "{&g-all},{&g-grp},{&g-choice},{&g-one}":U
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input ""
    , input no
    ).