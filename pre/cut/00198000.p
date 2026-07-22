block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00198000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00198000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 198.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-nws-doc-hist for src.nws-doc-hist.
define buffer new-nws-doc-hist for dst.nws-doc-hist.
define buffer old-nws-doc-hist-attr for src.nws-doc-hist-attr.
define buffer new-nws-doc-hist-attr for dst.nws-doc-hist-attr.
define buffer new-trn-doc     for dst.trn-doc.
define buffer new-rvs-doc     for dst.rvs-doc.
define buffer new-price-doc   for dst.price-doc.
define buffer new-fbr-doc     for dst.fbr-doc.
define buffer new-wth-doc     for dst.wth-doc.
define buffer new-icnt-doc    for dst.icnt-doc.
define buffer new-inkas       for dst.inkas.
define buffer new-ord-cons    for dst.ord-cons.
define buffer new-ord-doc     for dst.ord-doc.
define buffer new-ord-doc-rcv for dst.ord-doc-rcv.
do
on error undo, return error
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
  on write of dst.nws-doc-hist override do: end.
  on write of dst.nws-doc-hist-attr override do: end.
  define variable v-need-copy as logical   no-undo .
  for each old-nws-doc-hist no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    assign
      v-need-copy = false
    .
    case old-nws-doc-hist.doc-type
    :
      when 'trn-doc':u
      then do:
        find first new-trn-doc no-lock
          where new-trn-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-trn-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'rvs-doc':u
      then do:
        find first new-rvs-doc no-lock
          where new-rvs-doc.rvs-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-rvs-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'price-doc':u
      then do:
        find first new-price-doc no-lock
          where new-price-doc.doc-num = old-nws-doc-hist.doc-code
          no-error .
        if available new-price-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'fbr-doc':u
      then do:
        find first new-fbr-doc no-lock
          where new-fbr-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-fbr-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'wth-doc':u
      then do:
        find first new-wth-doc no-lock
          where new-wth-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-wth-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'icnt-doc':u
      then do:
        find first new-icnt-doc no-lock
          where new-icnt-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-icnt-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'inkas':u
      then do:
        find first new-inkas no-lock
          where new-inkas.inkas-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-inkas
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-cons':u
      then do:
        find first new-ord-cons no-lock
          where new-ord-cons.cons-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-cons
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-doc':u
      then do:
        find first new-ord-doc no-lock
          where new-ord-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-doc-rcv':u
      then do:
        find first new-ord-doc-rcv no-lock
          where new-ord-doc-rcv.rcv-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-doc-rcv
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
    end.
    if v-need-copy = true
    then do:
      create new-nws-doc-hist.
      buffer-copy old-nws-doc-hist to new-nws-doc-hist.
    end.
  end.
  for each old-nws-doc-hist-attr no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    find first new-nws-doc-hist no-lock where
              new-nws-doc-hist.db-num = old-nws-doc-hist-attr.db-num
           and new-nws-doc-hist.ord-num = old-nws-doc-hist-attr.ord-num no-error.
    if available new-nws-doc-hist then do:
      create new-nws-doc-hist-attr.
      buffer-copy old-nws-doc-hist-attr to new-nws-doc-hist-attr.
    end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: nws-doc-hist nws-doc-hist-attr .".
end.
