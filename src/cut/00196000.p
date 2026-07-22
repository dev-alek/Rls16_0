block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00196000.p $
$Archive: cut/00196000.p $

Файл пирога обрезания. Относится к категории 196.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц: c-doc-attr


*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00196000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00196000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 196.".
{ cmp/str-glbl.i }

define buffer old-c-doc-attr          for src.c-doc-attr.
define buffer new-c-doc-attr          for dst.c-doc-attr.

define buffer new-c-trn-doc            for dst.c-trn-doc  .
define buffer new-c-rvs-doc            for dst.c-rvs-doc  .
define buffer new-c-price-doc          for dst.c-price-doc.
define buffer new-c-fbr-doc            for dst.c-fbr-doc  .
define buffer new-c-wth-doc            for dst.c-wth-doc  .


do
on error undo, return error
:
  { utl/00000001.i }
  if not varstay-history  then return .
  on WRITE of dst.c-doc-attr      override do: end.

  for each new-c-trn-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-trn-doc.doc-code, new-c-trn-doc.chip-num) .
  end.

  for each new-c-rvs-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-rvs-doc.rvs-code, new-c-rvs-doc.chip-num) .
  end.

  for each new-c-price-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-price-doc.doc-num, new-c-price-doc.chip-num) .
  end.

  for each new-c-fbr-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-fbr-doc.doc-code, new-c-fbr-doc.chip-num) .
  end.

  for each new-c-wth-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-wth-doc.doc-code, new-c-wth-doc.chip-num) .
  end.

output stream str-gen close.
  return "Произведен экспорт таблиц: doc-attr.".
end.


procedure proc-1 :

  do
  on error undo, return error return-value
  :
  define input parameter p-doc as character no-undo .
  define input parameter p-chip-num as integer no-undo.

  for each old-c-doc-attr where old-c-doc-attr.doc-code = p-doc      and
                                old-c-doc-attr.chip-num = p-chip-num no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-c-doc-attr.
      BUFFER-COPY old-c-doc-attr to new-c-doc-attr.
  end.

  end.

end procedure. /* proc-1 */