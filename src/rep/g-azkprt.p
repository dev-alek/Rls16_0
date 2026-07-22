block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-azkprt.p $
$Archive: rep/g-azkprt.p $

Отчет протокол заправок

Автор: Хныкин Павел Андреевич
Дата создания: 09/24/07
Author: Pavel Khnykin
Creation date: 09/24/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-azkprt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-azkprt.p $":U .
define variable vss-description as character no-undo init "Отчет протокол заправок".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/r-azkprt.w'
    , input "Отчет протокол заправок":U
    , input 7
    , input ""
    , input "{&o-currency}"
    , input ""
    , input ""
    , input "all,{&Excel-yes}"
    , input yes
    ).