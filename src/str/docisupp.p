block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docisupp.p $
$Archive: str/docisupp.p $

Маленький толкач для просмотра из продажи оборота в учетных ценах - исключает конфликт по t-doc

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter rd as recid.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docisupp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/docisupp.p $":U .
define variable vss-description as character no-undo init "Маленький толкач для просмотра из продажи оборота в учетных ценах - исключает конфликт по t-doc".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

def new shared buffer t-doc for trn-doc.
find first t-doc where recid(t-doc) = rd no-lock no-error.
if not avail t-doc then return.

run str/docsuppn.w
  (input  parparentproc
  ,input  recid(t-doc)
  ).