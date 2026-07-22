block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-shftrl.p $
$Archive: rep/g-shftrl.p $

Реализация по сменам

Автор: Демин Алексей Сергеевич
Дата создания: 10/10/07
Author: Alexey Demin
Creation date: 10/10/07

*/

define input parameter parparentproc as widget-handle no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-shftrl.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-shftrl.p $":U .
def var vss-description as character no-undo init "Реализация по сменам ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i   new   }

run rep/d-report.w (
                input parparentproc ,
                input 'rep\r-shftrl.p',
                "Реализация по сменам",
                input 8,
                input "{&g-grp}",
                input "*",
                input "",
                input "",
                input "{&Excel-yes}",
                input yes).
/*                input "{&g-all},{&g-grp}",*/