block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wthrd.p $
$Archive: rep/g-wthrd.p $

Реестр документов движения серийных МЦ (старт)

Автор: Демин Алексей Сергеевич
Дата создания: 06/19/08
Author: Alexey Demin
Creation date: 06/19/08

*/
define input  parameter       parparentproc      as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-wthrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-wthrd.p $":U .
define variable vss-description as character no-undo init "Реестр документов движения серийных МЦ (старт)".
{ cmp/vssrevis.i }
{ cmp/r-page1.i new}

    run rep/d-report.w ( input parparentproc
                       , input "rep/e-wthrd.w":U
                       , input "Реестр документов движения серийных МЦ":U
                       , input 2
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "{&customer-yes}":U
                       , input no
                       ) .