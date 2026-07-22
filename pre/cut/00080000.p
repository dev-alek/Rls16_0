block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00080000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00080000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 80.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_old_c-contract         for src.c-contract        .
define buffer buf_old_c-contract-line    for src.c-contract-line   .
define buffer buf_old_c-contract-specif  for src.c-contract-specif .
define buffer buf_old_contract           for src.contract          .
define buffer buf_old_contract-line      for src.contract-line     .
define buffer buf_old_contract-specif    for src.contract-specif   .
define buffer buf_old_contract-attr           for src.contract-attr          .
define buffer buf_old_contract-line-attr      for src.contract-line-attr     .
define buffer buf_old_contract-specif-attr    for src.contract-specif-attr   .
define buffer buf_new_c-contract         for dst.c-contract        .
define buffer buf_new_c-contract-line    for dst.c-contract-line   .
define buffer buf_new_c-contract-specif  for dst.c-contract-specif .
define buffer buf_new_contract           for dst.contract          .
define buffer buf_new_contract-line      for dst.contract-line     .
define buffer buf_new_contract-specif    for dst.contract-specif   .
define buffer buf_new_contract-attr           for dst.contract-attr          .
define buffer buf_new_contract-line-attr      for dst.contract-line-attr     .
define buffer buf_new_contract-specif-attr    for dst.contract-specif-attr   .
define buffer new_goods                  for dst.goods   .
define buffer old-ext-classif         for src.ext-classif.
define buffer new-ext-classif         for dst.ext-classif.
on WRITE of dst.ext-classif            override do: end.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
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
  on WRITE of dst.c-contract        override do: end.
  on WRITE of dst.c-contract-line   override do: end.
  on WRITE of dst.c-contract-specif override do: end.
  on WRITE of dst.contract          override do: end.
  on WRITE of dst.contract-line     override do: end.
  on WRITE of dst.contract-specif   override do: end.
  on WRITE of dst.contract-attr          override do: end.
  on WRITE of dst.contract-line-attr     override do: end.
  on WRITE of dst.contract-specif-attr   override do: end.
  for each buf_old_contract no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    create buf_new_contract.
    buffer-copy buf_old_contract to buf_new_contract.
    for each buf_old_contract-line no-lock
      where buf_old_contract-line.host-code    = buf_old_contract.host-code
        and buf_old_contract-line.contract-num = buf_old_contract.contract-code
      :
      create buf_new_contract-line.
      buffer-copy buf_old_contract-line to buf_new_contract-line.
    end.
    for each buf_old_contract-specif no-lock
      where buf_old_contract-specif.host-code    = buf_old_contract.host-code
        and buf_old_contract-specif.contract-num = buf_old_contract.contract-code
      :
        find first new_goods no-lock where
                  new_goods.gds-code = buf_old_contract-specif.gds-code no-error .
        if available new_goods then do:
            create buf_new_contract-specif.
            buffer-copy buf_old_contract-specif to buf_new_contract-specif.
        end.
     END.
    for each buf_old_contract-line-attr no-lock
      where buf_old_contract-line-attr.host-code    = buf_old_contract.host-code
        and buf_old_contract-line-attr.contract-num = buf_old_contract.contract-code
      :
      create buf_new_contract-line-attr.
      buffer-copy buf_old_contract-line-attr to buf_new_contract-line-attr.
    end.
    for each buf_old_contract-specif-attr no-lock
      where buf_old_contract-specif-attr.host-code    = buf_old_contract.host-code
        and buf_old_contract-specif-attr.contract-num = buf_old_contract.contract-code
      :
        find first new_goods no-lock where
                   new_goods.gds-code = buf_old_contract-specif-ATTR.gds-code no-error .
        if available new_goods then do:
            create buf_new_contract-specif-attr.
            buffer-copy buf_old_contract-specif-attr to buf_new_contract-specif-attr.
        END.
    end.
    for each buf_old_contract-attr no-lock
      where buf_old_contract-attr.host-code    = buf_old_contract.host-code
        and buf_old_contract-attr.contract-code = buf_old_contract.contract-code
      :
      create buf_new_contract-attr.
      buffer-copy buf_old_contract-attr to buf_new_contract-attr.
    end.
    if varstay-history = yes then do:
      for each buf_old_c-contract no-lock
        where buf_old_c-contract.host-code     = buf_old_contract.host-code
          and buf_old_c-contract.contract-code = buf_old_contract.contract-code
        :
        create buf_new_c-contract.
        buffer-copy buf_old_c-contract to buf_new_c-contract.
      end.
      for each buf_old_c-contract-line no-lock
        where buf_old_c-contract-line.host-code    = buf_old_contract.host-code
          and buf_old_c-contract-line.contract-num = buf_old_contract.contract-code
        :
        create buf_new_c-contract-line.
        buffer-copy buf_old_c-contract-line to buf_new_c-contract-line.
      end.
      for each buf_old_c-contract-specif no-lock
        where buf_old_c-contract-specif.host-code    = buf_old_contract.host-code
          and buf_old_c-contract-specif.contract-num = buf_old_contract.contract-code
        :
        find first new_goods no-lock where
                   new_goods.gds-code = buf_old_c-contract-specif.gds-code no-error .
        if available new_goods then do:
            create buf_new_c-contract-specif.
            buffer-copy buf_old_c-contract-specif to buf_new_c-contract-specif.
        end.
      end.
    end.
  end.
for each old-ext-classif  where old-ext-classif.classif-subject = 'contract':U  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif.
   buffer-copy old-ext-classif to new-ext-classif.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: c-contract c-contract-line c-contract-specif contract contract-line contract-specif ext-classif.".
end.
