block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00043001.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. ".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-parts    for src.parts.
define buffer new-parts    for dst.parts.
define buffer new-clients  for dst.clients.
define buffer new-supplier for dst.clients.
define buffer new-goods    for dst.goods.
on WRITE of dst.parts override do: end.
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
if vardate-output-zone <> ? then do:
  for each old-parts where old-parts.out-code = 'out-zone':U no-lock ,
    first new-goods where new-goods.artic     = old-parts.artic     and
                          new-goods.prod-type = old-parts.prod-type and
                          new-goods.prod-code = old-parts.prod-code no-lock,
     first new-clients where new-clients.obj-type = old-parts.obj-type and
                             new-clients.obj-code = old-parts.obj-code no-lock,
       first new-supplier where new-supplier.obj-type = old-parts.supp-type and
                                new-supplier.obj-code = old-parts.supp-code no-lock on error undo, return error :
       if old-parts.fact-date >= vardate-output-zone and
          old-parts.status_    = no                  and
          old-parts.rsrv-free  = no                  and
          old-parts.fact-qnty  > 0                   then do:
         find first new-parts no-lock where
                    new-parts.obj-type    =  old-parts.obj-type  and
                    new-parts.obj-code    =  old-parts.obj-code  and
                    new-parts.artic       =  old-parts.artic     and
                    new-parts.prod-type   =  old-parts.prod-type and
                    new-parts.prod-code   =  old-parts.prod-code and
                    new-parts.in-code     =  old-parts.in-code   and
                    new-parts.out-code    =  old-parts.out-code  and
                    new-parts.part-code   =  old-parts.part-code no-error .
         if not available new-parts then do:
            create new-parts.
            buffer-copy old-parts to new-parts.
         end.
       end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт расходной зоны.".
end.
