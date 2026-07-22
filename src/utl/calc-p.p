block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calc-p.p $
$Archive: utl/calc-p.p $

Утилита пересчета переоценок

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calc-p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/calc-p.p $":U .
define variable vss-description as character no-undo init "Утилита пересчета переоценок".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define buffer buf_price-doc for price-doc.

for each buf_price-doc where buf_price-doc.status_ = {&act-overvalue} :
    run str/pr-oldd.p (buf_price-doc.doc-num )  .
end.