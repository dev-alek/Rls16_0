block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wthob.p $
$Archive: rep/g-wthob.p $

Оборотная ведомость талонов

Автор: Демин Алексей Сергеевич
Дата создания: 08/29/07
Author: Alexey Demin
Creation date: 08/29/07

Input:

Output:

*/
define input  parameter parparentproc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-wthob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-wthob.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость талонов".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

do
on error undo, return error
:
    run rep/d-report.w (
          input parparentproc
        , input "rep/e-wthob.w":U
        , input "Оборотная ведомость талонов":U
        , input 5
        , input "":U
        , input "{&o-firm},{&o-currency},{&o-choice}":U
        , input "":U
        , input "":U
        , input "all":U
        , input no
    ).
end.