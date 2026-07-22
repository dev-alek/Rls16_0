block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 784232a2254b, 2720, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн янв 18 10:14:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00049000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00049000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 9.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-BatchProcess for src.BatchProcess.
define buffer new-BatchProcess for dst.BatchProcess.
define buffer old-Filter       for ubfltsrc.Filter.
define buffer new-Filter       for ubfltdst.Filter.
define buffer new-goods        for dst.goods.
define buffer old-db-filter      for src.db-filter     .
define buffer old-db-filter-attr for src.db-filter-attr.
define buffer old-filter-attr    for ubfltsrc.filter-attr   .
define buffer new-db-filter      for dst.db-filter     .
define buffer new-db-filter-attr for dst.db-filter-attr.
define buffer new-filter-attr    for ubfltdst.filter-attr   .
define variable v-need-copy-batchprocess as logical   no-undo .
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
  on write  of dst.batchprocess     override do: end.
  on write  of ubfltdst.filter      override do: end.
  on create of ubfltdst.filter      override do: end.
  on WRITE  of dst.db-filter        override do: end.
  on WRITE  of dst.db-filter-attr   override do: end.
  on WRITE  of ubfltdst.filter-attr override do: end.
for each old-Filter  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-Filter.
   buffer-copy old-Filter to new-Filter.
end.
  for each old-BatchProcess no-lock
    where old-BatchProcess.bp_type = 'prc':U
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    run check-exist in this-procedure
      (input  'price-doc':u
      ,input  old-batchprocess.charkey_one
      ,output v-need-copy-batchprocess
      ) .
    if v-need-copy-batchprocess = true
    then do:
      create new-batchprocess.
      buffer-copy old-batchprocess to new-batchprocess.
    end.
  end.
  for each old-BatchProcess no-lock
    where old-BatchProcess.bp_type = 'trnhd':U
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    run check-exist in this-procedure
      (input  'trn-doc':u
      ,input  old-batchprocess.charkey_one
      ,output v-need-copy-batchprocess
      ) .
    if v-need-copy-batchprocess = true
    then do:
      create new-batchprocess.
      buffer-copy old-batchprocess to new-batchprocess.
    end.
  end.
  if vartype-cut = 1
  then do:
    for each old-BatchProcess no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      case old-BatchProcess.BP_type
      :
        when 'autonws':U or
        when 'autoarh':U or
        when 'autoexp':U or
        when 'autosuz':U or
        when 'autogcd':U or
        when 'autosale':U or
        when 'autocbnk':U or
        when 'autofree':U or
        when 'mercury':U or
        when 'hddtest':U or
        when 'is_motp':U or
        when 'is_diadoc':U or
        when 'is_PM':U
        then do:
        end.
        when 'cutdbs':U
        then do:
        end.
        when 'autoupg':U
        then do:
        end.
        when 'prc':U or
        when 'trnhd':U
        then do:
        end.
        when 'rt-doc':U or
        when 'rt-line':U or
        when 'bcprint':U
        then do:
        end.
        when 'arh':U
        then do:
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'ahsp':U
        then do:
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'aht':U
        then do:
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'hold':U
        then do:
          run check-exist in this-procedure
            (input  'trn-doc':u
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'hinv':U
        then do:
          run check-exist in this-procedure
            (input  'trn-doc':u
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'hspi':U
        then do:
          run check-exist in this-procedure
            (input  'trn-doc':u
            ,input  old-batchprocess.charkey_one
            ,output v-need-copy-batchprocess
            ) .
          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when 'gds':U
        then do:
           find first new-goods no-lock where
                  new-goods.gds-code   = old-BatchProcess.key#_one no-error.
           if available new-goods then do:
              create new-batchprocess.
              buffer-copy old-batchprocess to new-batchprocess.
           end.
        end.
        when 'dcard':U
        then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when 'goa':U
        then do:
           find first new-goods no-lock where
                  new-goods.gds-code   = old-BatchProcess.key#_one no-error.
           if available new-goods then do:
              create new-batchprocess.
              buffer-copy old-batchprocess to new-batchprocess.
           end.
        end.
        when 'slr':U
        then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when 'cshr':U
        then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when 'mvob':U
        then do:
        end.
        when 'bcode':U
        then do:
        end.
        when 'fgrp':U
        then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when 'rnar':U
        then do:
        end.
        when 'autooxml':U then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        otherwise do:
          if old-BatchProcess.BP_type begins 'lock':U
          or old-BatchProcess.BP_type begins 'lusr':U
          then do:
          end.
          else do:
            return error substitute("Неизвестный тип BatchProcess &1", old-BatchProcess.BP_type ) .
          end.
        end.
      end case.
    end.
  end.
for each old-db-filter  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-db-filter.
   buffer-copy old-db-filter to new-db-filter.
end.
for each old-db-filter-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-db-filter-attr.
   buffer-copy old-db-filter-attr to new-db-filter-attr.
end.
for each old-filter-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-filter-attr.
   buffer-copy old-filter-attr to new-filter-attr.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: BatchProcess Filter db-filter db-filter-attr filter-attr .".
end.
procedure check-exist :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-doc-code   as character no-undo .
  define output parameter p-need-copy  as logical   no-undo .
  define buffer new-trn-doc      for dst.trn-doc .
  define buffer new-price-doc    for dst.price-doc .
  do
  on error undo, return error return-value
  :
    assign
      p-need-copy = false
    .
    case p-table-name
    :
      when 'trn-doc':u
      then do:
        find first new-trn-doc no-lock
          where new-trn-doc.doc-code = p-doc-code
          no-error .
        if available new-trn-doc
        then do:
          assign
            p-need-copy = true
          .
        end.
      end.
      when 'price-doc':u
      then do:
        find first new-price-doc no-lock
          where new-price-doc.doc-num = p-doc-code
          no-error .
        if available new-price-doc
        then do:
          assign
            p-need-copy = true
          .
        end.
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип задания &1", p-table-name) .
      end.
    end case .
  end.
end procedure.
