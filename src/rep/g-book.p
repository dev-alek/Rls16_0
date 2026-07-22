block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-book.p $
$Archive: rep/g-book.p $

Книга покупок

Автор: Демин Алексей Сергеевич
Дата создания: 11/25/05
Author: Alexey Demin
Creation date: 11/25/05

*/

define input  parameter parParentProc as handle    no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-book.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-book.p $":U .
define variable vss-description as character no-undo init "Книга покупок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w
    ( input parParentProc ,
      input 'rep/r-book.p',
      "Книга покупок",
      2,
      "":U,
      "{&o-firm}",
      "",
      "",
      "",
      yes).