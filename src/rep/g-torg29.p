block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-torg29.p $
$Archive: rep/g-torg29.p $

Форма ТОРГ-29 (толкач)

Автор: Хныкин Павел Андреевич
Дата создания: 10/17/07
Author: Pavel Khnykin
Creation date: 10/17/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-torg29.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-torg29.p $":U .
define variable vss-description as character no-undo init "Форма ТОРГ-29 (толкач)".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

assign
  my-handle = parparentproc
.

run rep/d-report.w
    ( input parparentproc
    , input 'rep/r-torg29.p'
    , input "Форма ТОРГ-29":U
    , input 2
    , input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input "{&p-cost},{&p-crsa},{&p-sale}"
    , input "{&v-rubl},{&v-base}"
    , input "all,{&Arc-OT-yes},{&Excel-yes}"
    , input yes
    ).