block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00193000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00193000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 193.".
define buffer old-wealth         for src.wealth.
define buffer new-wealth         for dst.wealth.
define buffer old-c-wealth       for src.c-wealth.
define buffer new-c-wealth       for dst.c-wealth.
define buffer old-wealth-attr    for src.wealth-attr.
define buffer new-wealth-attr    for dst.wealth-attr.
define buffer old-wth-gds        for src.wth-gds.
define buffer new-wth-gds        for dst.wth-gds.
define buffer old-c-wth-gds      for src.c-wth-gds.
define buffer new-c-wth-gds      for dst.c-wth-gds.
define buffer old-wth-gds-attr   for src.wth-gds-attr.
define buffer new-wth-gds-attr   for dst.wth-gds-attr.
define buffer old-c-wth-gds-attr for src.c-wth-gds-attr.
define buffer new-c-wth-gds-attr for dst.c-wth-gds-attr.
define buffer old-wth-ser        for src.wth-ser.
define buffer new-wth-ser        for dst.wth-ser.
define buffer old-c-wth-ser      for src.c-wth-ser.
define buffer new-c-wth-ser      for dst.c-wth-ser.
define buffer old-wth-ser-attr   for src.wth-ser-attr.
define buffer new-wth-ser-attr   for dst.wth-ser-attr.
define buffer old-c-wth-ser-attr for src.c-wth-ser-attr.
define buffer new-c-wth-ser-attr for dst.c-wth-ser-attr.
define buffer old-wth-par        for src.wth-par.
define buffer new-wth-par        for dst.wth-par.
define buffer old-c-wth-par      for src.c-wth-par.
define buffer new-c-wth-par      for dst.c-wth-par.
define buffer old-wth-par-attr   for src.wth-par-attr.
define buffer new-wth-par-attr   for dst.wth-par-attr.
define buffer old-wth-obj        for src.wth-obj.
define buffer new-wth-obj        for dst.wth-obj.
define buffer old-c-wth-obj      for src.c-wth-obj.
define buffer new-c-wth-obj      for dst.c-wth-obj.
define buffer old-wth-obj-attr   for src.wth-obj-attr.
define buffer new-wth-obj-attr   for dst.wth-obj-attr.
define buffer old-wth-pobj       for src.wth-pobj.
define buffer new-wth-pobj       for dst.wth-pobj.
define buffer old-c-wth-pobj     for src.c-wth-pobj.
define buffer new-c-wth-pobj     for dst.c-wth-pobj.
define buffer old-wth-pobj-attr  for src.wth-pobj-attr.
define buffer new-wth-pobj-attr  for dst.wth-pobj-attr.
define buffer old-wth-place      for src.wth-place.
define buffer new-wth-place      for dst.wth-place.
define buffer old-c-wth-place    for src.c-wth-place.
define buffer new-c-wth-place    for dst.c-wth-place.
define buffer old-wth-place-attr for src.wth-place-attr.
define buffer new-wth-place-attr for dst.wth-place-attr.
define buffer old-c-wth-hist     for src.c-wth-hist.
define buffer new-c-wth-hist     for dst.c-wth-hist.
define buffer old-wth-doc        for src.wth-doc.
define buffer new-wth-doc        for dst.wth-doc.
define buffer old-wth-doc-attr   for src.wth-doc-attr.
define buffer new-wth-doc-attr   for dst.wth-doc-attr.
define buffer old-wth-line       for src.wth-line.
define buffer new-wth-line       for dst.wth-line.
define buffer old-wth-line-attr  for src.wth-line-attr.
define buffer new-wth-line-attr  for dst.wth-line-attr.
define buffer old-wth-dtl        for src.wth-dtl.
define buffer new-wth-dtl        for dst.wth-dtl.
define buffer old-wth-dtl-attr   for src.wth-dtl-attr.
define buffer new-wth-dtl-attr   for dst.wth-dtl-attr.
define buffer old-wth-parts      for src.wth-parts.
define buffer new-wth-parts      for dst.wth-parts.
define buffer old-wth-parts-attr for src.wth-parts-attr.
define buffer new-wth-parts-attr for dst.wth-parts-attr.
define buffer old-chk-doc  for src.chk-doc.
define buffer new-chk-doc  for dst.chk-doc.
define buffer old-chk-doc-attr  for src.chk-doc-attr.
define buffer new-chk-doc-attr  for dst.chk-doc-attr.
define buffer old-c-chk-doc-attr  for src.c-chk-doc-attr.
define buffer new-c-chk-doc-attr  for dst.c-chk-doc-attr.
define buffer old-chk-pay   for src.chk-pay .
define buffer new-chk-pay   for dst.chk-pay .
define buffer old-chk-pay-attr   for src.chk-pay-attr .
define buffer new-chk-pay-attr   for dst.chk-pay-attr .
define buffer old-c-chk-doc  for src.c-chk-doc.
define buffer new-c-chk-doc  for dst.c-chk-doc.
define buffer old-c-chk-pay   for src.c-chk-pay .
define buffer new-c-chk-pay   for dst.c-chk-pay.
define buffer new-goods      for dst.goods.
define buffer new-db      for dst.db .
define buffer new-clients    for dst.clients.
define variable varactual-goods  as logical no-undo.
define variable v-temp-date as date no-undo .
define variable v-fact-order as decimal no-undo .
define variable find-fact-order  as decimal no-undo .
define temp-table temp-new-wth-line no-undo like dst.wth-line.
define stream LogStream.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
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
on WRITE of dst.wealth          override do: end.
on WRITE of dst.c-wealth        override do: end.
on WRITE of dst.wealth-attr     override do: end.
on WRITE of dst.wth-gds         override do: end.
on WRITE of dst.c-wth-gds       override do: end.
on WRITE of dst.wth-gds-attr    override do: end.
on WRITE of dst.c-wth-gds-attr  override do: end.
on WRITE of dst.wth-ser         override do: end.
on WRITE of dst.c-wth-ser       override do: end.
on WRITE of dst.wth-ser-attr    override do: end.
on WRITE of dst.c-wth-ser-attr  override do: end.
on WRITE of dst.wth-par         override do: end.
on WRITE of dst.c-wth-par       override do: end.
on WRITE of dst.wth-par-attr    override do: end.
on WRITE of dst.wth-obj         override do: end.
on WRITE of dst.c-wth-obj       override do: end.
on WRITE of dst.wth-obj-attr    override do: end.
on WRITE of dst.wth-pobj        override do: end.
on WRITE of dst.c-wth-pobj      override do: end.
on WRITE of dst.wth-pobj-attr   override do: end.
on WRITE of dst.wth-place       override do: end.
on WRITE of dst.c-wth-place     override do: end.
on WRITE of dst.wth-place-attr  override do: end.
on WRITE of dst.c-wth-hist      override do: end.
on WRITE of dst.wth-doc         override do: end.
on WRITE of dst.wth-doc-attr    override do: end.
on WRITE of dst.wth-line        override do: end.
on WRITE of dst.wth-line-attr   override do: end.
on WRITE of dst.wth-dtl         override do: end.
on WRITE of dst.wth-dtl-attr    override do: end.
on WRITE of dst.wth-parts       override do: end.
on WRITE of dst.wth-parts-attr  override do: end.
on write of dst.chk-doc         override do: end.
on write of dst.chk-doc-attr    override do: end.
on write of dst.chk-pay         override do: end.
on write of dst.chk-pay-attr    override do: end.
on write of dst.c-chk-doc       override do: end.
on write of dst.c-chk-pay       override do: end.
for each old-wealth  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wealth.
   buffer-copy old-wealth to new-wealth.
end.
if varstay-history then do:
for each old-c-wealth  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wealth.
   buffer-copy old-c-wealth to new-c-wealth.
end.
end.
for each old-wealth-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wealth-attr.
   buffer-copy old-wealth-attr to new-wealth-attr.
end.
for each old-wth-ser  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-ser.
   buffer-copy old-wth-ser to new-wth-ser.
end.
for each old-wth-ser-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-ser-attr.
   buffer-copy old-wth-ser-attr to new-wth-ser-attr.
end.
if varstay-history then do:
for each old-c-wth-ser  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-ser.
   buffer-copy old-c-wth-ser to new-c-wth-ser.
end.
for each old-c-wth-ser-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-ser-attr.
   buffer-copy old-c-wth-ser-attr to new-c-wth-ser-attr.
end.
end.
for each old-wth-par  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-par.
   buffer-copy old-wth-par to new-wth-par.
end.
if varstay-history then do:
for each old-c-wth-par  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-par.
   buffer-copy old-c-wth-par to new-c-wth-par.
end.
end.
for each old-wth-par-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-par-attr.
   buffer-copy old-wth-par-attr to new-wth-par-attr.
end.
for each old-wth-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-obj.
   buffer-copy old-wth-obj to new-wth-obj.
end.
if varstay-history then do:
for each old-c-wth-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-obj.
   buffer-copy old-c-wth-obj to new-c-wth-obj.
end.
end.
for each old-wth-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-obj-attr.
   buffer-copy old-wth-obj-attr to new-wth-obj-attr.
end.
for each old-wth-pobj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-pobj.
   buffer-copy old-wth-pobj to new-wth-pobj.
end.
if varstay-history then do:
for each old-c-wth-pobj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-pobj.
   buffer-copy old-c-wth-pobj to new-c-wth-pobj.
end.
end.
for each old-wth-pobj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-pobj-attr.
   buffer-copy old-wth-pobj-attr to new-wth-pobj-attr.
end.
for each old-wth-place  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wth-place.
   buffer-copy old-wth-place to new-wth-place.
end.
if varstay-history then do:
for each old-c-wth-hist  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wth-hist.
   buffer-copy old-c-wth-hist to new-c-wth-hist.
end.
end.
for each old-wth-gds no-lock
on error undo, return error
:
    find first new-goods no-lock
          where new-goods.gds-code     = old-wth-gds.gds-code
    no-error.
    if available new-goods
    then do:
        create new-wth-gds.
        buffer-copy old-wth-gds to new-wth-gds.
    end.
end.
for each old-wth-gds-attr no-lock
on error undo, return error
:
    find first new-goods no-lock
          where new-goods.gds-code     = old-wth-gds-attr.gds-code
    no-error.
    if available new-goods
    then do:
        create new-wth-gds-attr.
        buffer-copy old-wth-gds-attr to new-wth-gds-attr.
    end.
end.
if varstay-history then do:
  for each old-c-wth-gds no-lock
  on error undo, return error
  :
      find first new-goods no-lock
            where new-goods.gds-code     = old-c-wth-gds.gds-code
      no-error.
      if available new-goods
      then do:
          create new-c-wth-gds.
          buffer-copy old-c-wth-gds to new-c-wth-gds.
      end.
  end.
  for each old-c-wth-gds-attr no-lock
  on error undo, return error
  :
      find first new-goods no-lock
            where new-goods.gds-code     = old-c-wth-gds-attr.gds-code
      no-error.
      if available new-goods
      then do:
          create new-c-wth-gds-attr.
          buffer-copy old-c-wth-gds-attr to new-c-wth-gds-attr.
      end.
  end.
end.
if vardate-actual-docs <> ? then  do:
  v-temp-date = vardate-actual-docs  - 1 .
end.
else  do:
  v-temp-date = today .
end.
assign
v-fact-order =  integer(v-temp-date) + 0.97 + 3 * 0.0000000001
find-fact-order =  integer(v-temp-date) + 0.99
.
if vardate-actual-docs <> ? then do:
  for each new-db no-lock
  ,each new-clients no-lock
    where new-clients.db-num = new-db.db-num
  :
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = new-clients.obj-type and
                                tt-objs.obj-code = new-clients.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
      for each old-wth-doc where
              old-wth-doc.host-code = new-clients.host-code
          and old-wth-doc.obj-type = new-clients.obj-type
          and old-wth-doc.obj-code = new-clients.obj-code
          and old-wth-doc.status_ = 'факт':U
          and old-wth-doc.fact-date >= vardate-actual-docs  no-lock
      use-index stat-fact
      on error undo, return error
      :
      create new-wth-doc.
      buffer-copy old-wth-doc to new-wth-doc.
        run copy-body in this-procedure ( input new-wth-doc.doc-code).
      end.
        for each new-wth-gds no-lock
        :
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = 'put-zone':U
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = 'cli-zone':U
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = 'free-zone':U
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
      end.
    end.
    for each temp-new-wth-line:
      delete temp-new-wth-line.
    end.
    for each old-wth-pobj
      where old-wth-pobj.host-code = new-clients.host-code
        and old-wth-pobj.obj-type  = new-clients.obj-type
        and old-wth-pobj.obj-code  = new-clients.obj-code
     on error undo, return error:
      find last old-wth-line no-lock where
                old-wth-line.obj-type   = new-clients.obj-type
            and old-wth-line.obj-code   = new-clients.obj-code
            and old-wth-line.w-p-code   = old-wth-pobj.w-p-code
            and old-wth-line.wth-code   = old-wth-pobj.wth-code
            and old-wth-line.fact-date  < vardate-actual-docs
            and old-wth-line.status_ = 'факт':U  use-index stat-cld-pl no-error.
      create temp-new-wth-line.
      if available old-wth-line then buffer-copy old-wth-line
      except doc-code ext-doc-type fact-date fact-order shift-date shift-num credate creid doc-sum bef-sum aft-sum
      to temp-new-wth-line.
      buffer-copy old-wth-pobj
      using
      host-code
      obj-code
      obj-type
      wth-code
      w-p-code
      to temp-new-wth-line
      .
      if available old-wth-line then
      assign
      temp-new-wth-line.bef-sum = old-wth-line.income-pl - old-wth-line.incass-pl
      temp-new-wth-line.aft-sum = temp-new-wth-line.bef-sum
      .
      else do:
        assign
        temp-new-wth-line.bef-sum = 0
        temp-new-wth-line.aft-sum = 0
        .
      end.
    end.
    find first temp-new-wth-line no-error.
    if available temp-new-wth-line then do:
      main-block:
      do
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        create dst.wth-doc.
        assign
        dst.wth-doc.cli-name   = new-clients.obj-name
        dst.wth-doc.doc-code   = "1-" + new-clients.obj-type  + string( new-clients.obj-code)
        dst.wth-doc.host-code  = new-clients.host-code
        dst.wth-doc.obj-type   = new-clients.obj-type
        dst.wth-doc.obj-code   = new-clients.obj-code
        dst.wth-doc.cli-type   = 'орг':U
        dst.wth-doc.cli-code   = new-clients.host-code
        dst.wth-doc.doc-date   = v-temp-date
        dst.wth-doc.fact-date  = v-temp-date
        dst.wth-doc.fact-order = v-fact-order
        dst.wth-doc.fact-num   = 3
        dst.wth-doc.shift-date = ?
        dst.wth-doc.shift-num  = ?
        dst.wth-doc.operator   = 0
        dst.wth-doc.deliver    = 0
        dst.wth-doc.receiver   = 0
        dst.wth-doc.inv-prs4   = 0
        dst.wth-doc.inv-prs5   = 0
        dst.wth-doc.doc-type   = 'инв':U
        dst.wth-doc.ext-doc-type = 'iy':U
        dst.wth-doc.auto-fill  = no
        dst.wth-doc.exter_     = yes
        dst.wth-doc.inter_     = no
        dst.wth-doc.PS         = "Инвентаризация создана в процессе обрезания базы (по остаткам на МХ МЦ на объекте) "
        dst.wth-doc.status_    = 'факт':U
        dst.wth-doc.creid      = USERID("dst")
        dst.wth-doc.credate    = v-temp-date
        .
        for each temp-new-wth-line
        on error undo, return error :
           create new-wth-line.
           buffer-copy temp-new-wth-line
           to new-wth-line.
           buffer-copy  dst.wth-doc
           using credate creid doc-code ext-doc-type fact-date fact-order shift-date shift-num obj-type obj-code status_
           to  new-wth-line.
           assign
           dst.wth-doc.bef-sum = dst.wth-doc.bef-sum + temp-new-wth-line.bef-sum
           dst.wth-doc.aft-sum = dst.wth-doc.aft-sum + temp-new-wth-line.aft-sum
           .
        end.
      end.
    end.
  end.
  if vardate-output-zone <> ? then do:
    for each new-db no-lock
    ,each new-clients no-lock
      where new-clients.db-num = new-db.db-num
    :
      for each new-wth-gds no-lock
      :
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type  = new-clients.obj-type
            and old-wth-parts.obj-code  = new-clients.obj-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = 'out-zone':U
        on error undo, return error
        :
          if old-wth-parts.fact-date >= vardate-output-zone  then do:
            create new-wth-parts.
            buffer-copy old-wth-parts to new-wth-parts.
          end.
        end.
      end.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: wealth c-wealth wealth-attr wth-ser wth-ser-attr c-wth-ser c-wth-ser-attr wth-gds c-wth-gds wth-gds-attr c-wth-gds-attr wth-par c-wth-par wth-part-attr ~
wth-obj c-wth-obj wth-obj-attr wth-place c-wth-place wth-place-attr wht-pobj c-wth-pobj wth-pobj-attr ~
wth-doc wth-doc-attr wth-line wth-line-attr wth-dtl wth-dtl-attr wth-parts wth-parts-attr chk-doc c-chk-doc chk-doc-attr chk-pay c-chk-pay chk-pay-attr chk-par c-chk-par chk-par-attr ".
end.
procedure copy-body :
define input parameter p-doc-code as character no-undo .
for each old-wth-line
  where old-wth-line.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-line.
    buffer-copy old-wth-line to new-wth-line.
end.
for each old-wth-doc-attr
  where old-wth-doc-attr.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-doc-attr.
    buffer-copy old-wth-doc-attr to new-wth-doc-attr.
end.
for each old-wth-line-attr
  where old-wth-line-attr.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-line-attr.
    buffer-copy old-wth-line-attr to new-wth-line-attr.
end.
for each old-wth-dtl
  where old-wth-dtl.doc-code  = p-doc-code no-lock
on error undo, return error
:
  create new-wth-dtl.
  buffer-copy old-wth-dtl to new-wth-dtl.
end.
for each old-wth-dtl-attr
  where old-wth-dtl-attr.doc-code  = p-doc-code no-lock
on error undo, return error
:
  create new-wth-dtl-attr.
  buffer-copy old-wth-dtl-attr to new-wth-dtl-attr.
end.
for each old-wth-parts
  where old-wth-parts.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-parts.
    buffer-copy old-wth-parts to new-wth-parts.
end.
for each old-wth-parts-attr
  where old-wth-parts-attr.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-parts-attr.
    buffer-copy old-wth-parts-attr to new-wth-parts-attr.
end.
for each old-chk-doc  no-lock
  where old-chk-doc.out-code = p-doc-code
on error undo, return error
:
    create new-chk-doc.
    buffer-copy old-chk-doc to new-chk-doc.
end.
for each old-c-chk-doc
  where  old-c-chk-doc.out-code = p-doc-code
  no-lock
on error undo, return error
:
    create new-c-chk-doc.
    buffer-copy old-c-chk-doc to new-c-chk-doc.
end.
for each old-chk-doc-attr no-lock
  where old-chk-doc-attr.out-code = p-doc-code
on error undo, return error
:
    create new-chk-doc-attr.
    buffer-copy old-chk-doc-attr to new-chk-doc-attr.
end.
for each old-c-chk-doc-attr no-lock
  where old-c-chk-doc-attr.out-code = p-doc-code
on error undo, return error
:
    create new-c-chk-doc-attr.
    buffer-copy old-c-chk-doc-attr to new-c-chk-doc-attr.
end.
for each old-chk-pay
  where old-chk-pay.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-chk-pay.
    buffer-copy old-chk-pay to new-chk-pay.
end.
for each old-c-chk-pay
  where old-c-chk-pay.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-c-chk-pay.
    buffer-copy old-c-chk-pay to new-c-chk-pay.
end.
for each old-chk-pay-attr no-lock
  where old-chk-pay-attr.out-code = p-doc-code
on error undo, return error
:
    create new-chk-pay-attr.
    buffer-copy old-chk-pay-attr to new-chk-pay-attr.
end.
end procedure.
