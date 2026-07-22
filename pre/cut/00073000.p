block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00073000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00073000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 13.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-curr-accnt for src.curr-accnt.
define buffer new-curr-accnt for dst.curr-accnt.
define buffer old-c-curr-accnt for src.c-curr-accnt.
define buffer new-c-curr-accnt for dst.c-curr-accnt.
define buffer old-curr-accnt-attr for src.curr-accnt-attr.
define buffer new-curr-accnt-attr for dst.curr-accnt-attr.
define buffer old-curr-bank  for src.curr-bank.
define buffer new-curr-bank  for dst.curr-bank.
define buffer old-c-curr-bank for src.c-curr-bank.
define buffer new-c-curr-bank for dst.c-curr-bank.
define buffer old-curr-bank-attr for src.curr-bank-attr.
define buffer new-curr-bank-attr for dst.curr-bank-attr.
define buffer old-currency   for src.currency.
define buffer new-currency   for dst.currency.
define buffer old-c-currency for src.c-currency.
define buffer new-c-currency for dst.c-currency.
define buffer old-currency-attr for src.currency-attr.
define buffer new-currency-attr for dst.currency-attr.
define buffer old-c-currency-attr for src.c-currency-attr.
define buffer new-c-currency-attr for dst.c-currency-attr.
define buffer old-curr-shop  for src.curr-shop.
define buffer new-curr-shop  for dst.curr-shop.
define buffer old-curr-shop-attr  for src.curr-shop-attr.
define buffer new-curr-shop-attr  for dst.curr-shop-attr.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
on WRITE of dst.curr-accnt override do: end.
on WRITE of dst.c-curr-accnt override do: end.
on WRITE of dst.curr-accnt-attr override do: end.
on WRITE of dst.curr-bank  override do: end.
on WRITE of dst.c-curr-bank override do: end.
on WRITE of dst.curr-bank-attr override do: end.
on WRITE of dst.currency   override do: end.
on WRITE of dst.c-currency override do: end.
on WRITE of dst.currency-attr override do: end.
on WRITE of dst.c-currency-attr override do: end.
on WRITE of dst.curr-shop  override do: end.
on WRITE of dst.curr-shop-attr  override do: end.
for each old-curr-accnt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-accnt.
   buffer-copy old-curr-accnt to new-curr-accnt.
end.
if varstay-history then do:
for each old-c-curr-accnt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-curr-accnt.
   buffer-copy old-c-curr-accnt to new-c-curr-accnt.
end.
end.
for each old-curr-accnt-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-accnt-attr.
   buffer-copy old-curr-accnt-attr to new-curr-accnt-attr.
end.
for each old-curr-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-bank.
   buffer-copy old-curr-bank to new-curr-bank.
end.
if varstay-history then do:
for each old-c-curr-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-curr-bank.
   buffer-copy old-c-curr-bank to new-c-curr-bank.
end.
end.
for each old-curr-bank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-bank-attr.
   buffer-copy old-curr-bank-attr to new-curr-bank-attr.
end.
for each old-currency  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-currency.
   buffer-copy old-currency to new-currency.
end.
if varstay-history then do:
for each old-c-currency  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-currency.
   buffer-copy old-c-currency to new-c-currency.
end.
end.
for each old-currency-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-currency-attr.
   buffer-copy old-currency-attr to new-currency-attr.
end.
if varstay-history then do:
for each old-c-currency-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-currency-attr.
   buffer-copy old-c-currency-attr to new-c-currency-attr.
end.
end.
for each old-curr-shop  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-shop.
   buffer-copy old-curr-shop to new-curr-shop.
end.
for each old-curr-shop-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-curr-shop-attr.
   buffer-copy old-curr-shop-attr to new-curr-shop-attr.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: curr-accnt c-curr-accnt curr-accnt-attr curr-bank c-curr-bank curr-bank-attr ~
currency c-currency currency-attr c-currency-attr curr-shop curr-shop-attr.".
end.
