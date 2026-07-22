block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00163000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00163000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 163.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-sert           for src.sert.
define buffer new-sert           for dst.sert.
define buffer old-c-sert         for src.c-sert.
define buffer new-c-sert         for dst.c-sert.
define buffer old-sert-attr      for src.sert-attr.
define buffer new-sert-attr      for dst.sert-attr.
define buffer old-sert-join      for src.sert-join.
define buffer new-sert-join      for dst.sert-join.
define buffer old-sert-join-attr for src.sert-join-attr.
define buffer new-sert-join-attr for dst.sert-join-attr.
define buffer new-clients   for dst.clients.
define buffer new-bar-code  for dst.bar-code.
define variable varmoved-sert as logical no-undo.
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
on WRITE of dst.sert      override do: end.
on WRITE of dst.c-sert         override do: end.
on WRITE of dst.sert-attr      override do: end.
on WRITE of dst.sert-join override do: end.
on WRITE of dst.sert-join-attr override do: end.
for each old-sert no-lock ,
   first new-clients where new-clients.obj-type = old-sert.cli-type and
                           new-clients.obj-code = old-sert.cli-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   assign varmoved-sert = yes.
   old-sert-join-label:
   for each old-sert-join where old-sert-join.cli-type  = old-sert.cli-type  and
                                old-sert-join.cli-code  = old-sert.cli-code  and
                                old-sert-join.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
       find first new-bar-code where new-bar-code.b-code = old-sert-join.b-code no-lock no-error.
       if not available new-bar-code then do:
          assign varmoved-sert = no.
          leave old-sert-join-label.
       end.
   end.
   if varmoved-sert = yes then do:
      create new-sert.
      buffer-copy old-sert to new-sert.
      for each old-sert-join where old-sert-join.cli-type  = old-sert.cli-type  and
                                   old-sert-join.cli-code  = old-sert.cli-code  and
                                   old-sert-join.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-join.
         buffer-copy old-sert-join to new-sert-join.
      end.
      for each old-sert-join-attr where old-sert-join-attr.cli-type  = old-sert.cli-type  and
                                   old-sert-join-attr.cli-code  = old-sert.cli-code  and
                                   old-sert-join-attr.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-join-attr.
         buffer-copy old-sert-join-attr to new-sert-join-attr.
      end.
      if varstay-history then do:
        for each old-c-sert where old-c-sert.cli-type  = old-sert.cli-type  and
                                    old-c-sert.cli-code  = old-sert.cli-code  and
                                    old-c-sert.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-sert.
          buffer-copy old-c-sert to new-c-sert.
        end.
      end.
      for each old-sert-attr where old-sert-attr.cli-type  = old-sert.cli-type  and
                                   old-sert-attr.cli-code  = old-sert.cli-code  and
                                   old-sert-attr.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-attr.
         buffer-copy old-sert-attr to new-sert-attr.
      end.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: sert c-sert sert-attr sert-join sert-joint-attr.".
end.
