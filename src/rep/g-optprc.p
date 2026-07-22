block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-optprc.p $
$Archive: rep/g-optprc.p $

Оптовый прайс-лист (толкач)

Автор: Хныкин Павел Андреевич
Дата создания: 11/26/08
Author: Pavel Khnykin
Creation date: 11/26/08
*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-optprc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-optprc.p $":U .
define variable vss-description as character no-undo init "Оптовый прайс-лист (толкач)".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

assign
  my-handle = parparentproc
.
run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-optprc.w'
    , input "Прайс-лист по переоценкам с учетом кодов на неосновные е.и.":U
    , input 0
    , input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U
    , input "{&o-currency}"
    , input ""
    , input ""
    , input "all"
    , input no
    ).