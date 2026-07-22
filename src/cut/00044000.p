block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00044000.p $
$Archive: cut/00044000.p $

Файл пирога обрезания. Относится к категории 44.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
price-doc
price-list

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00044000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00044000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 31.".
{ cmp/str-glbl.i }
define buffer old-price-doc   for src.price-doc.
define buffer new-price-doc   for dst.price-doc.
define buffer old-price-list  for src.price-list.
define buffer new-price-list  for dst.price-list.


define buffer old-parts       for src.parts.
define buffer buf_clients     for dst.clients.
define buffer new-parts       for dst.parts.

define buffer new-goods       for dst.goods .
define buffer new-bar-code    for dst.bar-code .
define buffer new-gds-prt     for dst.gds-prt  .

define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define variable p-bar-code     as integer   no-undo .

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
{ utl/tt-objs.i  }
on WRITE of dst.price-doc  override do: end.
on WRITE of dst.price-list override do: end.
on WRITE of dst.parts      override do: end.

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
          for each old-price-doc where old-price-doc.obj-type   = buf_clients.obj-type             and
                    old-price-doc.obj-code   = buf_clients.obj-CODE and
                    old-price-doc.status_    = {&act-overvalue}         and
                    old-price-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
            for each old-price-doc where old-price-doc.obj-type   = buf_clients.obj-type             and
                   old-price-doc.obj-code   = buf_clients.obj-CODE  and
                   old-price-doc.status_    = {&act-overvalue}
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
   /*Здесь должна быть процедура которая воссоздает переоценки
   Ее задачи:
   1) Если есть перегруженые строки в складских документах, но нет для них переоценок которые предворяют
      этот документ, то они должны быть воссозданы.
   2) После обрезания у оставшихся товаров должна быть текущая продажная цена если она была у него, дл
      этого следует также воссоздать переоценки.
   */
   output stream str-gen close.
end.
return "Произведен экспорт таблиц: price-doc price-list parts ( только переоценки )".
end.


procedure proc-copy :

  do
  on error undo, return error return-value
  :

  for each old-price-list where old-price-list.doc-num = old-price-doc.doc-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-price-list.
    buffer-copy old-price-list to new-price-list.

    if old-price-list.main-price = yes then do:
      for each old-parts where  old-parts.out-code  = old-price-doc.doc-num      and
                                old-parts.obj-code  = old-price-doc.obj-code    and
                                old-parts.obj-type  = old-price-doc.obj-type    and
                                old-parts.artic     = old-price-list.artic      and
                                old-parts.prod-code = old-price-list.prod-code  and
                                old-parts.prod-type = old-price-list.prod-type
                                no-lock on error undo,
                                return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                                :
          create new-parts.
          buffer-copy old-parts to new-parts.
      end.
    end.

  end.

  create new-price-doc.
  buffer-copy old-price-doc to new-price-doc.


  end.

end procedure. /* proc-copy */