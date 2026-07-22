block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wthobr.p $
$Archive: rep/g-wthobr.p $

Оборотная ведомость серийных МЦ по контрагентам

Автор: Хныкин Павел Андреевич
Дата создания: 12/25/07
Author: Pavel Khnykin
Creation date: 12/25/07

*/
define input  parameter parparentproc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-wthobr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-wthobr.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость серийных МЦ по контрагентам":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

do
on error undo, return error
:
    run rep/d-report.w ( input parparentproc
                       , input "rep/e-wthobr.w":U
                       , input "Оборотная ведомость серийных МЦ по контрагентам":U
                       , input 2
                       , input "":U
                       , input "{&o-firm}":U
                       , input "":U
                       , input "":U
                       , input "all,{&Excel-yes}":U
                       , input no
                       ) .
end.


