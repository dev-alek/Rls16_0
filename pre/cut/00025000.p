block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00025000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00025000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 25.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-place         for src.place.
define buffer new-place         for dst.place.
define buffer old-c-place       for src.c-place.
define buffer new-c-place       for dst.c-place.
define buffer old-place-attr    for src.place-attr.
define buffer new-place-attr    for dst.place-attr.
define buffer old-c-place-attr  for src.c-place-attr.
define buffer new-c-place-attr  for dst.c-place-attr.
define buffer old-pl-gds        for src.pl-gds.
define buffer new-pl-gds        for dst.pl-gds.
define buffer old-c-pl-gds      for src.c-pl-gds.
define buffer new-c-pl-gds      for dst.c-pl-gds.
define buffer old-c-pl-gds-obj  for src.c-pl-gds-obj.
define buffer new-c-pl-gds-obj  for dst.c-pl-gds-obj.
define buffer old-pl-gds-attr   for src.pl-gds-attr.
define buffer new-pl-gds-attr   for dst.pl-gds-attr.
define buffer old-c-pl-gds-attr for src.c-pl-gds-attr.
define buffer new-c-pl-gds-attr for dst.c-pl-gds-attr.
define buffer old-pl-gds-pump        for src.pl-gds-pump.
define buffer new-pl-gds-pump        for dst.pl-gds-pump.
define buffer old-c-pl-gds-pump      for src.c-pl-gds-pump.
define buffer new-c-pl-gds-pump      for dst.c-pl-gds-pump.
define buffer old-pl-gds-pump-attr   for src.pl-gds-pump-attr.
define buffer new-pl-gds-pump-attr   for dst.pl-gds-pump-attr.
define buffer old-c-pl-gds-pump-attr for src.c-pl-gds-pump-attr.
define buffer new-c-pl-gds-pump-attr for dst.c-pl-gds-pump-attr.
define buffer old-pl-pump       for src.pl-pump.
define buffer new-pl-pump       for dst.pl-pump.
define buffer old-c-pl-pump       for src.c-pl-pump.
define buffer new-c-pl-pump       for dst.c-pl-pump.
define buffer old-pl-pump-attr       for src.pl-pump-attr.
define buffer new-pl-pump-attr       for dst.pl-pump-attr.
define buffer old-c-pl-pump-attr       for src.c-pl-pump-attr.
define buffer new-c-pl-pump-attr       for dst.c-pl-pump-attr.
define buffer old-pump          for src.pump.
define buffer new-pump          for dst.pump.
define buffer old-c-pump          for src.c-pump.
define buffer new-c-pump          for dst.c-pump.
define buffer old-pump-attr          for src.pump-attr.
define buffer new-pump-attr          for dst.pump-attr.
define buffer old-c-pump-attr          for src.c-pump-attr.
define buffer new-c-pump-attr          for dst.c-pump-attr.
define buffer old-pl-pump-nozzle for src.pl-pump-nozzle.
define buffer new-pl-pump-nozzle for dst.pl-pump-nozzle.
define buffer old-c-pl-pump-nozzle for src.c-pl-pump-nozzle.
define buffer new-c-pl-pump-nozzle for dst.c-pl-pump-nozzle.
define buffer old-pl-pump-nozzle-attr for src.pl-pump-nozzle-attr.
define buffer new-pl-pump-nozzle-attr for dst.pl-pump-nozzle-attr.
define buffer old-c-pl-pump-nozzle-attr for src.c-pl-pump-nozzle-attr.
define buffer new-c-pl-pump-nozzle-attr for dst.c-pl-pump-nozzle-attr.
define buffer old-pump-nozzle    for src.pump-nozzle.
define buffer new-pump-nozzle    for dst.pump-nozzle.
define buffer old-c-pump-nozzle  for src.c-pump-nozzle.
define buffer new-c-pump-nozzle  for dst.c-pump-nozzle.
define buffer old-pump-nozzle-attr    for src.pump-nozzle-attr.
define buffer new-pump-nozzle-attr    for dst.pump-nozzle-attr.
define buffer old-c-pump-nozzle-attr  for src.c-pump-nozzle-attr.
define buffer new-c-pump-nozzle-attr  for dst.c-pump-nozzle-attr.
define buffer old-nozzle         for src.nozzle.
define buffer new-nozzle         for dst.nozzle.
define buffer old-c-nozzle       for src.c-nozzle.
define buffer new-c-nozzle       for dst.c-nozzle.
define buffer old-nozzle-attr    for src.nozzle-attr.
define buffer new-nozzle-attr    for dst.nozzle-attr.
define buffer old-c-nozzle-attr  for src.c-nozzle-attr.
define buffer new-c-nozzle-attr  for dst.c-nozzle-attr.
define buffer old-auto-tank      for src.auto-tank.
define buffer new-auto-tank      for dst.auto-tank.
define buffer old-c-auto-tank      for src.c-auto-tank.
define buffer new-c-auto-tank      for dst.c-auto-tank.
define buffer old-auto-tank-meas for src.auto-tank-meas.
define buffer new-auto-tank-meas for dst.auto-tank-meas.
define buffer old-auto-tank-attr for src.auto-tank-attr.
define buffer new-auto-tank-attr for dst.auto-tank-attr.
define buffer old-c-auto-tank-attr      for src.c-auto-tank-attr.
define buffer new-c-auto-tank-attr      for dst.c-auto-tank-attr.
define buffer old-auto-tank-meas-attr for src.auto-tank-meas-attr.
define buffer new-auto-tank-meas-attr for dst.auto-tank-meas-attr.
define buffer old-c-auto-tank-meas-attr for src.c-auto-tank-meas-attr.
define buffer new-c-auto-tank-meas-attr for dst.c-auto-tank-meas-attr.
define buffer old-pl-level      for src.pl-level.
define buffer new-pl-level      for dst.pl-level.
define buffer old-c-pl-level      for src.c-pl-level.
define buffer new-c-pl-level      for dst.c-pl-level.
define buffer old-pl-level-attr      for src.pl-level-attr.
define buffer new-pl-level-attr      for dst.pl-level-attr.
define buffer old-c-pl-level-attr      for src.c-pl-level-attr.
define buffer new-c-pl-level-attr      for dst.c-pl-level-attr.
define buffer old-c-plc-hist     for src.c-plc-hist.
define buffer new-c-plc-hist     for dst.c-plc-hist.
define buffer old-c-pmp-hist     for src.c-pmp-hist.
define buffer new-c-pmp-hist     for dst.c-pmp-hist.
define buffer old-c-nzl-hist     for src.c-nzl-hist.
define buffer new-c-nzl-hist     for dst.c-nzl-hist.
define buffer new-goods for dst.goods.
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
  on WRITE of dst.place          override do: end.
  on WRITE of dst.c-place        override do: end.
  on WRITE of dst.place-attr     override do: end.
  on WRITE of dst.c-place-attr   override do: end.
  on WRITE of dst.pl-gds         override do: end.
  on WRITE of dst.c-pl-gds       override do: end.
  on WRITE of dst.c-pl-gds-obj   override do: end.
  on WRITE of dst.pl-gds-attr    override do: end.
  on WRITE of dst.c-pl-gds-attr  override do: end.
  on WRITE of dst.pl-gds-pump    override do: end.
  on WRITE of dst.c-pl-gds-pump  override do: end.
  on WRITE of dst.pl-gds-pump-attr    override do: end.
  on WRITE of dst.c-pl-gds-pump-attr  override do: end.
  on WRITE of dst.pl-pump        override do: end.
  on WRITE of dst.c-pl-pump      override do: end.
  on WRITE of dst.pl-pump-attr   override do: end.
  on WRITE of dst.c-pl-pump-attr override do: end.
  on WRITE of dst.pump           override do: end.
  on WRITE of dst.c-pump         override do: end.
  on WRITE of dst.pump-attr      override do: end.
  on WRITE of dst.c-pump-attr    override do: end.
  on WRITE of dst.pl-pump-nozzle  override do: end.
  on WRITE of dst.c-pl-pump-nozzle  override do: end.
  on WRITE of dst.pl-pump-nozzle-attr  override do: end.
  on WRITE of dst.c-pl-pump-nozzle-attr  override do: end.
  on WRITE of dst.pump-nozzle        override do: end.
  on WRITE of dst.c-pump-nozzle      override do: end.
  on WRITE of dst.pump-nozzle-attr   override do: end.
  on WRITE of dst.c-pump-nozzle-attr override do: end.
  on WRITE of dst.nozzle          override do: end.
  on WRITE of dst.c-nozzle        override do: end.
  on WRITE of dst.nozzle-attr     override do: end.
  on WRITE of dst.c-nozzle-attr   override do: end.
  on WRITE of dst.auto-tank       override do: end.
  on WRITE of dst.c-auto-tank       override do: end.
  on WRITE of dst.auto-tank-attr  override do: end.
  on WRITE of dst.c-auto-tank-attr  override do: end.
  on WRITE of dst.c-plc-hist     override do: end.
  on WRITE of dst.c-pmp-hist     override do: end.
  on WRITE of dst.c-nzl-hist     override do: end.
  on WRITE of dst.auto-tank-meas  override do: end.
  on WRITE of dst.auto-tank-meas-attr  override do: end.
  on WRITE of dst.c-auto-tank-meas-attr  override do: end.
  on WRITE of dst.pl-level         override do: end.
  on WRITE of dst.c-pl-level       override do: end.
  on WRITE of dst.pl-level-attr  override do: end.
  on WRITE of dst.c-pl-level-attr  override do: end.
for each old-place  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-place.
   buffer-copy old-place to new-place.
end.
  if varstay-history then do:
for each old-c-place  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-place.
   buffer-copy old-c-place to new-c-place.
end.
  end.
for each old-place-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-place-attr.
   buffer-copy old-place-attr to new-place-attr.
end.
  if varstay-history then do:
for each old-c-place-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-place-attr.
   buffer-copy old-c-place-attr to new-c-place-attr.
end.
  end.
for each old-pump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pump.
   buffer-copy old-pump to new-pump.
end.
  if varstay-history then do:
for each old-c-pump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pump.
   buffer-copy old-c-pump to new-c-pump.
end.
  end.
for each old-pump-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pump-attr.
   buffer-copy old-pump-attr to new-pump-attr.
end.
  if varstay-history then do:
for each old-c-pump-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pump-attr.
   buffer-copy old-c-pump-attr to new-c-pump-attr.
end.
  end.
for each old-pl-pump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-pump.
   buffer-copy old-pl-pump to new-pl-pump.
end.
  if varstay-history then do:
for each old-c-pl-pump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-pump.
   buffer-copy old-c-pl-pump to new-c-pl-pump.
end.
  end.
for each old-pl-pump-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-pump-attr.
   buffer-copy old-pl-pump-attr to new-pl-pump-attr.
end.
  if varstay-history then do:
for each old-c-pl-pump-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-pump-attr.
   buffer-copy old-c-pl-pump-attr to new-c-pl-pump-attr.
end.
  end.
for each old-pl-pump-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-pump-nozzle.
   buffer-copy old-pl-pump-nozzle to new-pl-pump-nozzle.
end.
  if varstay-history then do:
for each old-c-pl-pump-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-pump-nozzle.
   buffer-copy old-c-pl-pump-nozzle to new-c-pl-pump-nozzle.
end.
  end.
for each old-pl-pump-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-pump-nozzle-attr.
   buffer-copy old-pl-pump-nozzle-attr to new-pl-pump-nozzle-attr.
end.
  if varstay-history then do:
for each old-c-pl-pump-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-pump-nozzle-attr.
   buffer-copy old-c-pl-pump-nozzle-attr to new-c-pl-pump-nozzle-attr.
end.
  end.
for each old-pump-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pump-nozzle.
   buffer-copy old-pump-nozzle to new-pump-nozzle.
end.
  if varstay-history then do:
for each old-c-pump-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pump-nozzle.
   buffer-copy old-c-pump-nozzle to new-c-pump-nozzle.
end.
  end.
for each old-pump-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pump-nozzle-attr.
   buffer-copy old-pump-nozzle-attr to new-pump-nozzle-attr.
end.
  if varstay-history then do:
for each old-c-pump-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pump-nozzle-attr.
   buffer-copy old-c-pump-nozzle-attr to new-c-pump-nozzle-attr.
end.
  end.
for each old-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-nozzle.
   buffer-copy old-nozzle to new-nozzle.
end.
  if varstay-history then do:
for each old-c-nozzle  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-nozzle.
   buffer-copy old-c-nozzle to new-c-nozzle.
end.
  end.
for each old-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-nozzle-attr.
   buffer-copy old-nozzle-attr to new-nozzle-attr.
end.
  if varstay-history then do:
for each old-c-nozzle-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-nozzle-attr.
   buffer-copy old-c-nozzle-attr to new-c-nozzle-attr.
end.
  end.
  for each old-pl-gds no-lock
    ,first new-goods no-lock
    where new-goods.gds-code  = old-pl-gds.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds.
    buffer-copy old-pl-gds to new-pl-gds.
  end.
  if varstay-history then do:
    for each old-c-pl-gds no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds.
      buffer-copy old-c-pl-gds to new-c-pl-gds.
    end.
    for each old-c-pl-gds-obj no-lock
      ,first new-goods no-lock
      where new-goods.gds-code = old-c-pl-gds-obj.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-obj.
      buffer-copy old-c-pl-gds-obj to new-c-pl-gds-obj.
    end.
  end.
  for each old-pl-gds-attr no-lock
    ,first new-goods no-lock
    where new-goods.gds-code = old-pl-gds-attr.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-attr.
    buffer-copy old-pl-gds-attr to new-pl-gds-attr.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-attr no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-attr.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-attr.
      buffer-copy old-c-pl-gds-attr to new-c-pl-gds-attr.
    end.
  end.
  for each old-pl-gds-pump no-lock
    ,first new-goods no-lock
    where new-goods.gds-code  = old-pl-gds-pump.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-pump.
    buffer-copy old-pl-gds-pump to new-pl-gds-pump.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-pump no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-pump.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-pump.
      buffer-copy old-c-pl-gds-pump to new-c-pl-gds-pump.
    end.
  end.
  for each old-pl-gds-pump-attr no-lock
    ,first new-goods no-lock
    where new-goods.gds-code = old-pl-gds-pump-attr.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-pump-attr.
    buffer-copy old-pl-gds-pump-attr to new-pl-gds-pump-attr.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-pump-attr no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-pump-attr.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-pump-attr.
      buffer-copy old-c-pl-gds-pump-attr to new-c-pl-gds-pump-attr.
    end.
  end.
  if varstay-history then do:
    for each old-c-plc-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if old-c-plc-hist.subject = 'pl-gds':U
      or old-c-plc-hist.subject = 'pl-gds-pump':U
      or old-c-plc-hist.subject = 'pl-gds-attr':U
      or old-c-plc-hist.subject = 'pl-gds-pump-attr':U
      then do:
        find first new-goods where new-goods.gds-code  = old-c-plc-hist.gds-code no-lock no-error.
        if not available new-goods then do:
          next.
        end.
      end.
      create new-c-plc-hist.
      buffer-copy old-c-plc-hist to new-c-plc-hist.
    end.
    for each old-c-pmp-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if old-c-pmp-hist.subject = 'pl-gds-pump':U
      or old-c-pmp-hist.subject = 'pl-gds-pump-attr':U
      then do:
        find first new-goods where new-goods.gds-code  = old-c-pmp-hist.gds-code no-lock no-error.
        if not available new-goods then do:
          next.
        end.
      end.
      create new-c-pmp-hist.
      buffer-copy old-c-pmp-hist to new-c-pmp-hist.
    end.
    for each old-c-nzl-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      create new-c-nzl-hist.
      buffer-copy old-c-nzl-hist to new-c-nzl-hist.
    end.
  end.
for each old-auto-tank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-auto-tank.
   buffer-copy old-auto-tank to new-auto-tank.
end.
  if varstay-history then do:
for each old-c-auto-tank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-auto-tank.
   buffer-copy old-c-auto-tank to new-c-auto-tank.
end.
  end.
for each old-auto-tank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-auto-tank-attr.
   buffer-copy old-auto-tank-attr to new-auto-tank-attr.
end.
  if varstay-history then do:
for each old-c-auto-tank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-auto-tank-attr.
   buffer-copy old-c-auto-tank-attr to new-c-auto-tank-attr.
end.
  end.
for each old-auto-tank-meas  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-auto-tank-meas.
   buffer-copy old-auto-tank-meas to new-auto-tank-meas.
end.
for each old-auto-tank-meas-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-auto-tank-meas-attr.
   buffer-copy old-auto-tank-meas-attr to new-auto-tank-meas-attr.
end.
  if varstay-history then do:
for each old-c-auto-tank-meas-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-auto-tank-meas-attr.
   buffer-copy old-c-auto-tank-meas-attr to new-c-auto-tank-meas-attr.
end.
  end.
for each old-pl-level  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-level.
   buffer-copy old-pl-level to new-pl-level.
end.
  if varstay-history then do:
for each old-c-pl-level  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-level.
   buffer-copy old-c-pl-level to new-c-pl-level.
end.
  end.
for each old-pl-level-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pl-level-attr.
   buffer-copy old-pl-level-attr to new-pl-level-attr.
end.
  if varstay-history then do:
for each old-c-pl-level-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pl-level-attr.
   buffer-copy old-c-pl-level-attr to new-c-pl-level-attr.
end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: place c-place place-attr c-place-attr pl-gds c-pl-gds c-pl-gds-obj pl-gds-attr c-pl-gds-attr ~
  pl-gds-pump c-pl-gds-pump pl-gds-pump-attr c-pl-gds-pump-attr pump c-pump pump-attr c-pump-attr pl-pump c-pl-pump pl-pump-attr c-pl-pump-attr pl-pump-nozzle c-pl-pump-nozzle ~
  pl-pump-nozzle-attr c-pl-pump-nozzle-attr pump-nozzle c-pump-nozzle pump-nozzle-attr c-pump-nozzle-attr nozzle c-nozzle nozzle-attr c-nozzle-attr ~
  auto-tank c-auto-tank auto-tank-meas auto-tank-attr c-auto-tank-attr auto-tank-meas-attr c-auto-tank-meas-attr c-plc-hist c-nzl-hist c-pmp-hist ~
  pl-level c-pl-level pl-level-attr c-pl-level-attr  " .
end.
