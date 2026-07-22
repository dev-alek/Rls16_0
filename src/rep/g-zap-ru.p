block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-zap-ru.p $
$Archive: rep/g-zap-ru.p $

Состояние запаса для Ручки.ру

Автор: Демин Алексей Сергеевич
Дата создания: 10/10/07
Author: Alexey Demin
Creation date: 10/10/07

*/

define input parameter parparentproc as widget-handle no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-zap-ru.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-zap-ru.p $":U .
def var vss-description as character no-undo init "Состояние запаса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w ( input parparentproc ,
                 input 'rep/r-zap-ru.p',
                 "Состояние запаса",
                 input 1,
                 input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}",
                 input "*",
                 input "",
                 input "",
                 input "{&Arc-ot-yes}",
/*                 input "{&Excel-yes}",*/
                 input yes).