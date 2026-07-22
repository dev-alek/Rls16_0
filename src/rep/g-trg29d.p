block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-trg29d.p $
$Archive: rep/g-trg29d.p $

Форма ТОРГ-29 по документам (толкач)

Автор: Демин Алексей Сергеевич
Дата создания: 07/30/08
Author: Alexey Demin
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-trg29d.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-trg29d.p $":U .
define variable vss-description as character no-undo init "Форма ТОРГ-29 по документам (толкач)".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-trg29d.w'
    , input "Форма ТОРГ-29 по документам":U
    , input 4
    , input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U
    , input "*"
    , input "{&p-cost},{&p-crsa},{&p-sale}"
    , input "{&v-rubl},{&v-base}"
    , input "all,{&Arc-OT-yes},{&Excel-yes},{&send-check}"
    , input no
    ).