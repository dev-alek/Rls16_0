block-level on error undo, throw.
 /*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-gpcst.p $
$Archive: rep/g-gpcst.p $

Журнал продаж с ГТД и счетами-фактурами (компания СИМПЛ)

Author: Alexey Suslov
Creation date: 02/19/09
Автор: Суслов Алексей Юрьевич
Дата создания: 02/19/09

*/
define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-gpcst.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-gpcst.p $":U .
def var vss-description as character no-undo init "Реализация с печатью накладной поставщика и ГТД (компания СИМПЛ)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w ( input parParentProc,
                     input 'rep/r-gpcst.p',
                     input ('Реализация с печатью накладной поставщика и ГТД'),
                     2,
                     "{&g-all}",
                     "*",
                     "",
                     "",
                     "shop,{&news-arj},{&Excel-yes}",
                     yes).