block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00045000.p $
$Archive: cut/00045000.p $

Файл пирога обрезания. Относится к категории 45.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
c-price-doc
c-price-list
c-price-list-attr

*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00045000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00045000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 45.".
{ cmp/str-glbl.i }

define buffer old-c-price-doc   for src.c-price-doc.
define buffer new-c-price-doc   for dst.c-price-doc.
define buffer old-c-price-list  for src.c-price-list.
define buffer new-c-price-list  for dst.c-price-list.
define buffer old-c-price-list-attr  for src.c-price-list-attr.
define buffer new-c-price-list-attr  for dst.c-price-list-attr.

define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
{ utl/tt-objs.i  }

if not varstay-history then return .

define buffer buf_clients for src.clients .

on WRITE of dst.c-price-doc  override do: end.
on WRITE of dst.c-price-list override do: end.
on WRITE of dst.c-price-list-attr override do: end.

if vardate-actual-docs <> ? then do:

    for each buf_clients no-lock  where
             buf_clients.db-num <> ?
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :

      if vartype-cut = 1 then do:
          find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                   tt-objs.obj-code = buf_clients.obj-code no-error.
      end.

      if vartype-cut = 0      or
          (vartype-cut = 1 and available tt-objs) then do:
                     if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
                            for each old-c-price-doc where
                                      old-c-price-doc.obj-type   = buf_clients.obj-TYPE  and
                                      old-c-price-doc.obj-code   = buf_clients.obj-code  and
                                      old-c-price-doc.status_    = {&act-overvalue}      and
                                      old-c-price-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                                RUN proc-copy no-error .
                                IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
                            end.
                     end.
      end.
      else do:
                    if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
                            for each old-c-price-doc where
                                      old-c-price-doc.obj-type   = buf_clients.obj-TYPE  and
                                      old-c-price-doc.obj-code   = buf_clients.obj-code  and
                                      old-c-price-doc.status_    = {&act-overvalue}
                                      no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                                RUN proc-copy no-error .
                                IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
                            end.
                     end.
      end.
  END.
output stream str-gen close.
END.
return "Произведен экспорт таблиц: c-price-doc c-price-list ( только переоценки )".
end.


procedure proc-copy :

  do
  on error undo, return error return-value
  :
  for each old-c-price-list where old-c-price-list.doc-num  = old-c-price-doc.doc-num  and
                                  old-c-price-list.chip-num = old-c-price-doc.chip-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-c-price-list.
      buffer-copy old-c-price-list to new-c-price-list.

  end.
  for each old-c-price-list-attr where old-c-price-list-attr.doc-num  = old-c-price-doc.doc-num  and
                                        old-c-price-list-attr.chip-num = old-c-price-doc.chip-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-c-price-list-attr.
      buffer-copy old-c-price-list-attr to new-c-price-list-attr.
  end.

  create new-c-price-doc.
  buffer-copy old-c-price-doc to new-c-price-doc.

  end.

end procedure. /* proc-copy */