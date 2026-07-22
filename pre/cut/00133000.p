block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00133000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00133000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 133.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-pay-type for src.pay-type.
define buffer new-pay-type for dst.pay-type.
define buffer old-c-pay-type for src.c-pay-type.
define buffer new-c-pay-type for dst.c-pay-type.
define buffer old-pay-type-attr for src.pay-type-attr.
define buffer new-pay-type-attr for dst.pay-type-attr.
define buffer old-c-pay-type-attr for src.c-pay-type-attr.
define buffer new-c-pay-type-attr for dst.c-pay-type-attr.
define buffer old-trn-reason for src.trn-reason.
define buffer new-trn-reason for dst.trn-reason.
define buffer old-c-trn-reason for src.c-trn-reason.
define buffer new-c-trn-reason for dst.c-trn-reason.
define buffer old-trn-reason-host for src.trn-reason-host.
define buffer new-trn-reason-host for dst.trn-reason-host.
define buffer old-c-trn-reason-host for src.c-trn-reason-host.
define buffer new-c-trn-reason-host for dst.c-trn-reason-host.
define buffer old-trn-reason-obj for src.trn-reason-obj.
define buffer new-trn-reason-obj for dst.trn-reason-obj.
define buffer old-c-trn-reason-obj for src.c-trn-reason-obj.
define buffer new-c-trn-reason-obj for dst.c-trn-reason-obj.
define buffer old-trn-rsn-attr for src.trn-rsn-attr.
define buffer new-trn-rsn-attr for dst.trn-rsn-attr.
define buffer old-c-trn-rsn-attr for src.c-trn-rsn-attr.
define buffer new-c-trn-rsn-attr for dst.c-trn-rsn-attr.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
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
on WRITE of dst.pay-type override do: end.
on WRITE of dst.c-pay-type override do: end.
on WRITE of dst.pay-type-attr override do: end.
on WRITE of dst.c-pay-type-attr override do: end.
on WRITE of dst.trn-reason override do: end.
on WRITE of dst.c-trn-reason override do: end.
on WRITE of dst.trn-reason-host override do: end.
on WRITE of dst.c-trn-reason-host override do: end.
on WRITE of dst.trn-reason-obj override do: end.
on WRITE of dst.c-trn-reason-obj override do: end.
on WRITE of dst.trn-reason override do: end.
on WRITE of dst.c-trn-rsn-attr override do: end.
on WRITE of dst.trn-rsn-attr override do: end.
for each old-pay-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pay-type.
   buffer-copy old-pay-type to new-pay-type.
end.
if varstay-history then do:
for each old-c-pay-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pay-type.
   buffer-copy old-c-pay-type to new-c-pay-type.
end.
end.
for each old-pay-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pay-type-attr.
   buffer-copy old-pay-type-attr to new-pay-type-attr.
end.
if varstay-history then do:
for each old-c-pay-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pay-type-attr.
   buffer-copy old-c-pay-type-attr to new-c-pay-type-attr.
end.
end.
for each old-trn-reason  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-trn-reason.
   buffer-copy old-trn-reason to new-trn-reason.
end.
if varstay-history then do:
for each old-c-trn-reason  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-trn-reason.
   buffer-copy old-c-trn-reason to new-c-trn-reason.
end.
end.
for each old-trn-rsn-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-trn-rsn-attr.
   buffer-copy old-trn-rsn-attr to new-trn-rsn-attr.
end.
if varstay-history then do:
for each old-c-trn-rsn-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-trn-rsn-attr.
   buffer-copy old-c-trn-rsn-attr to new-c-trn-rsn-attr.
end.
end.
for each old-trn-reason-host  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-trn-reason-host.
   buffer-copy old-trn-reason-host to new-trn-reason-host.
end.
if varstay-history then do:
for each old-c-trn-reason-host  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-trn-reason-host.
   buffer-copy old-c-trn-reason-host to new-c-trn-reason-host.
end.
end.
for each old-trn-reason-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-trn-reason-obj.
   buffer-copy old-trn-reason-obj to new-trn-reason-obj.
end.
if varstay-history then do:
for each old-c-trn-reason-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-trn-reason-obj.
   buffer-copy old-c-trn-reason-obj to new-c-trn-reason-obj.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: pay-type c-pay-type pay-type-attr c-pay-type-attr ~
trn-reason c-trn-reason trn-rsn-attr c-trn-rsn-attr ~
trn-reason-host c-trn-reason-host trn-reason-obj c-trn-reason-obj.".
end.
