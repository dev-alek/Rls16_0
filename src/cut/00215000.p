block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00215000.p $
$Archive: cut/00215000.p $

Файл пирога обрезания. Относится к категории 215.

Автор: Чернова Светлана Александровна
Дата создания: 05/22/09
Author: Svetlana Chernova
Creation date: 05/22/09

Обработка таблиц:

criterion-analysis
criterion-analysis-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00215000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00215000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 215.".
{ cmp/str-glbl.i }

define buffer old-criterion-analysis          for src.criterion-analysis.
define buffer new-criterion-analysis          for dst.criterion-analysis.
define buffer old-criterion-analysis-attr     for src.criterion-analysis-attr.
define buffer new-criterion-analysis-attr     for dst.criterion-analysis-attr.


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.criterion-analysis            override do: end.
  on WRITE of dst.criterion-analysis-attr       override do: end.



  { utl/00000002.i criterion-analysis      }
  { utl/00000002.i criterion-analysis-attr }

output stream str-gen close.
  return "Произведен экспорт таблиц: criterion-analysis criterion-analysis-attr  . " .
end.