block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00044002.p $
$Archive: cut/00044002.p $

Файл пирога обрезания. Относится к категории 43.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
price-list-attr


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00044002.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00044002.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 43.".
{ cmp/str-glbl.i }

define buffer old-price-list    for src.price-list.
define buffer new-price-doc     for dst.price-doc.
define buffer old-price-list-attr    for src.price-list-attr.
define buffer new-price-list-attr    for dst.price-list-attr.



do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.price-list-attr       override do: end.


  for each new-price-doc no-lock :
      for each old-price-list-attr no-lock  where
          old-price-list-attr.doc-num = new-price-doc.doc-num and
          old-price-list-attr.price-type = ""
          on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
          :
          create new-price-list-attr.
          BUFFER-COPY old-price-list-attr to new-price-list-attr.
      end.

  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: price-list-attr .".
end.