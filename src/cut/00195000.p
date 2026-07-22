block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00195000.p $
$Archive: cut/00195000.p $

Файл пирога обрезания. Относится к категории 195.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:

doc-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00195000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00195000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 195.".
{ cmp/str-glbl.i }

define buffer old-doc-attr          for src.doc-attr.
define buffer new-doc-attr          for dst.doc-attr.

define buffer new-trn-doc            for dst.trn-doc  .
define buffer new-rvs-doc            for dst.rvs-doc  .
define buffer new-price-doc          for dst.price-doc.
define buffer new-fbr-doc            for dst.fbr-doc  .
define buffer new-wth-doc            for dst.wth-doc  .
define buffer new-icnt-doc           for dst.icnt-doc .


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.doc-attr      override do: end.

  for each new-trn-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-trn-doc.doc-code) .
  end.

  for each new-rvs-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-rvs-doc.rvs-code) .
  end.

  for each new-price-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-price-doc.doc-num) .
  end.

  for each new-fbr-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-fbr-doc.doc-code) .
  end.

  for each new-wth-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-wth-doc.doc-code) .
  end.

  for each new-icnt-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-icnt-doc.doc-code) .
  end.

output stream str-gen close.
  return "Произведен экспорт таблиц: doc-attr.".
end.


procedure proc-1 :

  do
  on error undo, return error return-value
  :
  define input  parameter p-doc as character no-undo .

  for each old-doc-attr where old-doc-attr.doc-code = p-doc
      no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      find first new-doc-attr where new-doc-attr.doc-code  = old-doc-attr.doc-code  and
                                    new-doc-attr.attr-code = old-doc-attr.attr-code no-error.
      if not available new-doc-attr then do:
        create new-doc-attr.
        buffer-copy old-doc-attr to new-doc-attr.
      end.
  end.

  end.

end procedure. /* proc-1 */