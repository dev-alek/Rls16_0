block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00139000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00139000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 139.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-pck-rcvd        for src.pck-rcvd.
define buffer new-pck-rcvd        for dst.pck-rcvd.
define buffer old-pck-rcvd-attr        for src.pck-rcvd-attr.
define buffer new-pck-rcvd-attr        for dst.pck-rcvd-attr.
define buffer old-pck-sent        for src.pck-sent.
define buffer new-pck-sent        for dst.pck-sent.
define buffer old-pck-sent-attr   for src.pck-sent-attr.
define buffer new-pck-sent-attr   for dst.pck-sent-attr.
define buffer old-pck-keys        for src.pck-keys.
define buffer new-pck-keys        for dst.pck-keys.
define buffer old-route           for src.route.
define buffer new-route           for dst.route.
define buffer old-route-attr      for src.route-attr.
define buffer new-route-attr      for dst.route-attr.
define buffer old-route-dump      for src.route-dump.
define buffer new-route-dump      for dst.route-dump.
define buffer old-route-dump-attr for src.route-dump-attr.
define buffer new-route-dump-attr for dst.route-dump-attr.
define buffer old-route-dump-link for src.route-dump-link.
define buffer new-route-dump-link for dst.route-dump-link.
do
on error undo, return error substitute( "&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2))
on stop  undo, return error substitute( "stop" )
:
  define variable v-msg as character no-undo .
  define buffer buf_db for src.db .
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
  on write of dst.route override do: end.
  on write of dst.pck-rcvd override do: end.
  on write of dst.pck-rcvd-attr override do: end.
  on write of dst.pck-sent override do: end.
  on write of dst.pck-sent-attr override do: end.
  if vartype-cut = 0 then do:
    for each buf_db
    on error undo, return error substitute( "&1 &2", return-value, error-status :get-message ( 1 ) )
    :
      find last old-pck-sent
        where old-pck-sent.db-num = buf_db.db-num
        use-index pi
        no-error
      .
      if available old-pck-sent then do:
        create new-pck-sent.
        buffer-copy old-pck-sent to new-pck-sent
          assign
            new-pck-sent.pack-num   = 0
            new-pck-sent.rcvd       = true
            new-pck-sent.total-recs = 0
        .
      end.
      find last old-pck-rcvd
        where old-pck-rcvd.db-num = buf_db.db-num
        use-index pi
        no-error
      .
      if available old-pck-rcvd then do:
        create new-pck-rcvd.
        buffer-copy old-pck-rcvd to new-pck-rcvd
          assign
            new-pck-rcvd.pack-num   = 0
            new-pck-rcvd.rcvd-recs  = 0
            new-pck-rcvd.rcvd       = true
            new-pck-rcvd.total-recs = 0
        .
      end.
    end.
    assign
      v-msg = "Игнорированы таблицы:"
    .
  end.
  else do:
for each old-pck-rcvd  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pck-rcvd.
   buffer-copy old-pck-rcvd to new-pck-rcvd.
end.
for each old-pck-rcvd-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pck-rcvd-attr.
   buffer-copy old-pck-rcvd-attr to new-pck-rcvd-attr.
end.
for each old-pck-sent  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pck-sent.
   buffer-copy old-pck-sent to new-pck-sent.
end.
for each old-pck-sent-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pck-sent-attr.
   buffer-copy old-pck-sent-attr to new-pck-sent-attr.
end.
for each old-pck-keys  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pck-keys.
   buffer-copy old-pck-keys to new-pck-keys.
end.
for each old-route  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-route.
   buffer-copy old-route to new-route.
end.
for each old-route-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-route-attr.
   buffer-copy old-route-attr to new-route-attr.
end.
for each old-route-dump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-route-dump.
   buffer-copy old-route-dump to new-route-dump.
end.
for each old-route-dump-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-route-dump-attr.
   buffer-copy old-route-dump-attr to new-route-dump-attr.
end.
for each old-route-dump-link  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-route-dump-link.
   buffer-copy old-route-dump-link to new-route-dump-link.
end.
    assign
      v-msg = "Произведен экспорт таблиц:"
    .
  end.
output stream str-gen close.
  return substitute( "&1 pck-rcvd, pck-rcvd-attr, pck-sent, pck-sent-attr, pck-keys, route, route-attr, route-dump, route-dump-attr, route-dump-link.", v-msg ).
end.
