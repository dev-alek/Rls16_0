block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00043000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
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
define buffer old-trn-doc        for src.trn-doc        .
define buffer new-trn-doc        for dst.trn-doc        .
define buffer old-doc-line       for src.doc-line       .
define buffer new-doc-line       for dst.doc-line       .
define buffer old-doc-line-attr  for src.doc-line-attr  .
define buffer new-doc-line-attr  for dst.doc-line-attr  .
define buffer old-doc-pl         for src.doc-pl         .
define buffer new-doc-pl         for dst.doc-pl         .
define buffer old-doc-pl-attr    for src.doc-pl-attr    .
define buffer new-doc-pl-attr    for dst.doc-pl-attr    .
define buffer old-doc-pl-pump    for src.doc-pl-pump    .
define buffer new-doc-pl-pump    for dst.doc-pl-pump    .
define buffer old-doc-pl-pump-attr    for src.doc-pl-pump-attr    .
define buffer new-doc-pl-pump-attr    for dst.doc-pl-pump-attr    .
define buffer old-doc-fbr-gds    for src.doc-fbr-gds    .
define buffer new-doc-fbr-gds    for dst.doc-fbr-gds    .
define buffer old-gds-dtl-attr   for src.gds-dtl-attr   .
define buffer old-gds-dtl        for src.gds-dtl        .
define buffer new-gds-dtl-attr   for dst.gds-dtl-attr        .
define buffer new-gds-dtl        for dst.gds-dtl        .
define buffer old-parts          for src.parts          .
define buffer new-parts          for dst.parts          .
define buffer old-doc-prts       for src.doc-prts       .
define buffer new-doc-prts       for dst.doc-prts       .
define buffer old-doc-prts-attr  for src.doc-prts-attr       .
define buffer new-doc-prts-attr  for dst.doc-prts-attr       .
define buffer old-inv-doc        for src.inv-doc        .
define buffer new-inv-doc        for dst.inv-doc        .
define buffer old-inv-doc-attr   for src.inv-doc-attr   .
define buffer new-inv-doc-attr   for dst.inv-doc-attr   .
define buffer old-inv-line       for src.inv-line       .
define buffer new-inv-line       for dst.inv-line       .
define buffer old-c-inv-line     for src.c-inv-line       .
define buffer new-c-inv-line     for dst.c-inv-line       .
define buffer old-inv-line-attr  for src.inv-line-attr  .
define buffer new-inv-line-attr  for dst.inv-line-attr  .
define buffer old-chk-doc        for src.chk-doc        .
define buffer new-chk-doc        for dst.chk-doc        .
define buffer old-chk-gds        for src.chk-gds        .
define buffer new-chk-gds        for dst.chk-gds        .
define buffer old-chk-gds-pay        for src.chk-gds-pay        .
define buffer new-chk-gds-pay        for dst.chk-gds-pay        .
define buffer old-chk-gds-attr        for src.chk-gds-attr        .
define buffer new-chk-gds-attr        for dst.chk-gds-attr        .
define buffer old-chk-pay        for src.chk-pay        .
define buffer new-chk-pay        for dst.chk-pay        .
define buffer old-chk-pay-attr        for src.chk-pay-attr        .
define buffer new-chk-pay-attr        for dst.chk-pay-attr        .
define buffer old-chk-discnt     for src.chk-discnt     .
define buffer new-chk-discnt     for dst.chk-discnt     .
define buffer old-chk-discnt-attr for src.chk-discnt-attr .
define buffer new-chk-discnt-attr for dst.chk-discnt-attr  .
define buffer old-chk-doc-attr   for src.chk-doc-attr   .
define buffer new-chk-doc-attr   for dst.chk-doc-attr   .
define buffer old-c-chk-doc      for src.c-chk-doc        .
define buffer new-c-chk-doc      for dst.c-chk-doc        .
define buffer old-c-chk-gds      for src.c-chk-gds        .
define buffer new-c-chk-gds      for dst.c-chk-gds        .
define buffer old-c-chk-pay      for src.c-chk-pay        .
define buffer new-c-chk-pay      for dst.c-chk-pay        .
define buffer old-c-chk-discnt   for src.c-chk-discnt     .
define buffer new-c-chk-discnt   for dst.c-chk-discnt     .
define buffer old-c-chk-doc-attr for src.c-chk-doc-attr   .
define buffer new-c-chk-doc-attr for dst.c-chk-doc-attr   .
define buffer old-inkas          for src.inkas          .
define buffer new-inkas          for dst.inkas          .
define buffer old-c-inkas        for src.c-inkas          .
define buffer new-c-inkas        for dst.c-inkas          .
define buffer old-inkas-pay      for src.inkas-pay      .
define buffer new-inkas-pay      for dst.inkas-pay      .
define buffer old-c-inkas-pay      for src.c-inkas-pay      .
define buffer new-c-inkas-pay      for dst.c-inkas-pay      .
define buffer old-inkas-pay-desk for src.inkas-pay-desk .
define buffer new-inkas-pay-desk for dst.inkas-pay-desk .
define buffer old-c-inkas-pay-desk for src.c-inkas-pay-desk .
define buffer new-c-inkas-pay-desk for dst.c-inkas-pay-desk .
define buffer old-inkas-pay-attr      for src.inkas-pay-attr      .
define buffer new-inkas-pay-attr      for dst.inkas-pay-attr      .
define buffer old-inkas-pay-desk-attr for src.inkas-pay-desk-attr .
define buffer new-inkas-pay-desk-attr for dst.inkas-pay-desk-attr .
define buffer old-inkas-pay-wth      for src.inkas-pay-wth      .
define buffer new-inkas-pay-wth      for dst.inkas-pay-wth      .
define buffer old-c-inkas-pay-wth    for src.c-inkas-pay-wth  .
define buffer new-c-inkas-pay-wth    for dst.c-inkas-pay-wth  .
define buffer old-sale-doc       for src.sale-doc       .
define buffer new-sale-doc       for dst.sale-doc       .
define buffer old-sale-doc-attr  for src.sale-doc-attr  .
define buffer new-sale-doc-attr  for dst.sale-doc-attr  .
define buffer old-c-sale-doc       for src.c-sale-doc       .
define buffer new-c-sale-doc       for dst.c-sale-doc       .
define buffer old-edi-status   for src.edi-status  .
define buffer new-edi-status   for dst.edi-status  .
define buffer new-shop           for dst.shop         .
define buffer new-store          for dst.store        .
define buffer new-goods          for dst.goods        .
do
on error undo, return error
:
  on write of dst.trn-doc         override do: end.
  on write of dst.doc-line        override do: end.
  on write of dst.doc-line-attr   override do: end.
  on write of dst.doc-pl          override do: end.
  on write of dst.doc-pl-attr     override do: end.
  on write of dst.doc-pl-pump     override do: end.
  on write of dst.doc-pl-pump-attr override do: end.
  on write of dst.doc-fbr-gds     override do: end.
  on write of dst.gds-dtl         override do: end.
  on write of dst.gds-dtl-attr    override do: end.
  on write of dst.parts           override do: end.
  on write of dst.doc-prts        override do: end.
  on write of dst.doc-prts-attr   override do: end.
  on write of dst.inv-doc         override do: end.
  on write of dst.inv-doc-attr    override do: end.
  on write of dst.inv-line        override do: end.
  on write of dst.c-inv-line      override do: end.
  on write of dst.inv-line-attr   override do: end.
  on write of dst.chk-doc         override do: end.
  on write of dst.chk-doc-attr    override do: end.
  on write of dst.chk-gds         override do: end.
  on write of dst.chk-gds-attr    override do: end.
  on write of dst.chk-gds-pay     override do: end.
  on write of dst.chk-pay         override do: end.
  on write of dst.chk-pay-attr    override do: end.
  on write of dst.chk-discnt      override do: end.
  on write of dst.chk-discnt-attr override do: end.
  on write of dst.c-chk-doc       override do: end.
  on write of dst.c-chk-doc-attr  override do: end.
  on write of dst.c-chk-gds       override do: end.
  on write of dst.c-chk-pay       override do: end.
  on write of dst.c-chk-discnt    override do: end.
  on write of dst.inkas           override do: end.
  on write of dst.c-inkas         override do: end.
  on write of dst.inkas-pay       override do: end.
  on write of dst.c-inkas-pay       override do: end.
  on write of dst.inkas-pay-desk  override do: end.
  on write of dst.c-inkas-pay-desk  override do: end.
  on write of dst.inkas-pay-attr  override do: end.
  on write of dst.inkas-pay-desk-attr override do: end.
  on write of dst.inkas-pay-wth    override do: end.
  on write of dst.c-inkas-pay-wth  override do: end.
  on write of dst.sale-doc        override do: end.
  on write of dst.sale-doc-attr   override do: end.
  on write of dst.c-sale-doc      override do: end.
 on write of dst.edi-status      override do: end.
  define buffer new-db      for dst.db .
  define buffer new-clients for dst.clients .
  for each new-db no-lock
  ,each new-clients no-lock
    where new-clients.db-num = new-db.db-num
  :
    if vardate-actual-docs <> ? then do:
      if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = new-clients.obj-type and
                                 tt-objs.obj-code = new-clients.obj-code no-error.
      end.
      if vartype-cut = 0      or
         (vartype-cut = 1 and available tt-objs) then do:
        for each old-trn-doc where old-trn-doc.obj-type   = new-clients.obj-type  and
                                   old-trn-doc.obj-code   = new-clients.obj-code and
                                   old-trn-doc.status_    = 'факт':U              and
                                   old-trn-doc.fact-date >= vardate-actual-docs  no-lock
        use-index stat-fact
        on error undo, return error
        :
          run copy-body in this-procedure.
        end.
      end.
      else do:
        for each old-trn-doc where old-trn-doc.obj-type   = new-clients.obj-type  and
                                   old-trn-doc.obj-code   = new-clients.obj-code and
                                   old-trn-doc.status_    = 'факт':U
        use-index stat-fact
        on error undo, return error
        :
          run copy-body in this-procedure.
        end.
      end.
    end.
    for each new-goods no-lock
    :
      for each old-parts no-lock
        where old-parts.obj-type  = new-clients.obj-type
          and old-parts.obj-code  = new-clients.obj-code
          and old-parts.artic     = new-goods.artic
          and old-parts.prod-type = new-goods.prod-type
          and old-parts.prod-code = new-goods.prod-code
          and old-parts.status_   = false
          and old-parts.rsrv-free = true
          and old-parts.in-code   <> old-parts.out-code
          and old-parts.qnty      <> 0
      on error undo, return error
      :
        find first new-parts
          where new-parts.obj-type  = old-parts.obj-type
            and new-parts.obj-code  = old-parts.obj-code
            and new-parts.artic     = old-parts.artic
            and new-parts.prod-type = old-parts.prod-type
            and new-parts.prod-code = old-parts.prod-code
            and new-parts.in-code   = old-parts.in-code
            and new-parts.out-code  = 'free-zone':U
            and new-parts.part-code = old-parts.part-code
          no-error .
        if not available new-parts then do:
          create new-parts.
          buffer-copy old-parts to new-parts
          assign
            new-parts.out-code  = 'free-zone':U
            new-parts.qnty      = 0
            new-parts.fact-qnty = 0
            new-parts.cli-qnty  = 0
            new-parts.real-qnty = 0
          .
        end.
        define variable v-parts-qnty     as decimal   no-undo .
        define variable v-parts-cli-qnty as decimal   no-undo .
        if old-parts.out-code = 'free-zone':U then do:
          assign
            v-parts-qnty     = old-parts.qnty
            v-parts-cli-qnty = old-parts.cli-qnty
          .
        end.
        else do:
          assign
            v-parts-qnty     = abs(old-parts.qnty)
            v-parts-cli-qnty = abs(old-parts.cli-qnty)
          .
        end.
        assign
          new-parts.qnty      = new-parts.qnty      + v-parts-qnty
          new-parts.fact-qnty = new-parts.qnty
          new-parts.real-qnty = new-parts.qnty
          new-parts.cli-qnty  = new-parts.cli-qnty  + v-parts-cli-qnty
        .
      end.
      define buffer new_out_parts for dst.parts .
      for each new-parts
        where new-parts.obj-type  = new-clients.obj-type
          and new-parts.obj-code  = new-clients.obj-code
          and new-parts.artic     = new-goods.artic
          and new-parts.prod-type = new-goods.prod-type
          and new-parts.prod-code = new-goods.prod-code
          and new-parts.out-code  = 'free-zone':U
          and new-parts.fact-qnty < 0
      on error undo, return error
      :
        if vardate-output-zone = ? or
           new-parts.fact-date < vardate-output-zone then do:
          create new_out_parts .
          buffer-copy new-parts to new_out_parts
          assign
            new_out_parts.out-code  = 'out-zone':U
            new_out_parts.rsrv-free = false
            new_out_parts.qnty      = abs(new-parts.fact-qnty)
            new_out_parts.fact-qnty = abs(new-parts.fact-qnty)
            new_out_parts.real-qnty = abs(new-parts.fact-qnty)
          .
        end.
      end.
    end.
  end.
  for each old-chk-discnt-attr,
        first new-chk-doc no-lock where
              new-chk-doc.doc-code = old-chk-discnt-attr.doc-code:
    create new-chk-discnt-attr.
    buffer-copy old-chk-discnt-attr to new-chk-discnt-attr.
  end.
  for each old-chk-gds-attr,
        first new-chk-doc no-lock where
              new-chk-doc.doc-code = old-chk-gds-attr.doc-code:
    create new-chk-gds-attr.
    buffer-copy old-chk-gds-attr to new-chk-gds-attr.
  end.
  for each old-chk-pay-attr,
        first new-chk-doc no-lock where
              new-chk-doc.doc-code = old-chk-pay-attr.doc-code:
    create new-chk-pay-attr.
    buffer-copy old-chk-pay-attr to new-chk-pay-attr.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: trn-doc doc-line doc-line-attr doc-pl doc-pl-attr doc-pl-pump doc-pl-pump-attr doc-fbr-gds gds-dtl parts doc-prts ~
  inv-doc  inv-doc-attr inv-line c-inv-line inv-line-attr trn-tax chk-doc chk-gds chk-gds-attr chk-gds-pay chk-pay chk-pay-attr chk-discnt chk-discnt-attr ~
  inkas c-inkas inkas-pay c-inkas-pay inkas-pay-desk c-inkas-pay-desk inkas-pay-attr inkas-pay-desk-attr inkas-pay-wth c-inkas-pay-wth ~
   sale-doc sale-doc-attr c-sale-doc edi-status.".
end.
procedure copy-body:
create new-trn-doc.
buffer-copy old-trn-doc to new-trn-doc.
for each old-doc-line
  where old-doc-line.doc-code = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-line.
    buffer-copy old-doc-line to new-doc-line.
end.
for each old-doc-line-attr
  where old-doc-line-attr.doc-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-line-attr.
    buffer-copy old-doc-line-attr to new-doc-line-attr.
end.
for each old-doc-pl
  where old-doc-pl.out-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-pl.
    buffer-copy old-doc-pl to new-doc-pl.
end.
for each old-doc-pl-attr
  where old-doc-pl-attr.out-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-pl-attr.
    buffer-copy old-doc-pl-attr to new-doc-pl-attr.
end.
for each old-doc-pl-pump
  where old-doc-pl-pump.out-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-pl-pump.
    buffer-copy old-doc-pl-pump to new-doc-pl-pump.
end.
for each old-doc-pl-pump-attr
  where old-doc-pl-pump-attr.out-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-pl-pump-attr.
    buffer-copy old-doc-pl-pump-attr to new-doc-pl-pump-attr.
end.
for each old-gds-dtl
  where old-gds-dtl.doc-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
  create new-gds-dtl.
  buffer-copy old-gds-dtl to new-gds-dtl.
end.
for each old-gds-dtl-attr
  where old-gds-dtl-attr.doc-code  = new-trn-doc.doc-code no-lock
on error undo, return error
:
  create new-gds-dtl.
  buffer-copy old-gds-dtl-attr to new-gds-dtl-attr.
end.
find first old-inv-doc
  where old-inv-doc.doc-code = new-trn-doc.doc-code no-lock
  no-error .
if available old-inv-doc then do:
  create new-inv-doc.
  buffer-copy old-inv-doc to new-inv-doc.
end.
for each old-inv-line
    where old-inv-line.doc-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inv-line.
      buffer-copy old-inv-line to new-inv-line.
end.
if varstay-history  then for each old-c-inv-line
    where old-c-inv-line.doc-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-inv-line.
      buffer-copy old-c-inv-line to new-c-inv-line.
end.
for each old-inv-line-attr
    where old-inv-line-attr.doc-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inv-line-attr.
      buffer-copy old-inv-line-attr to new-inv-line-attr.
end.
for each old-inv-doc-attr
    where old-inv-doc-attr.doc-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inv-doc-attr.
      buffer-copy old-inv-doc-attr to new-inv-doc-attr.
end.
for each old-doc-prts
  where old-doc-prts.out-code = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-prts.
    buffer-copy old-doc-prts to new-doc-prts.
end.
for each old-doc-prts-attr
  where old-doc-prts-attr.out-code = new-trn-doc.doc-code no-lock
on error undo, return error
:
    create new-doc-prts-attr.
    buffer-copy old-doc-prts-attr to new-doc-prts-attr.
end.
for each old-parts
  where old-parts.out-code = new-trn-doc.doc-code no-lock
use-index out-code
on error undo, return error
:
    create new-parts.
    buffer-copy old-parts to new-parts.
end.
if old-trn-doc.ext-doc-type = 'es':U
or old-trn-doc.ext-doc-type = 'rs':U
then do:
  for each old-doc-fbr-gds
    where old-doc-fbr-gds.out-code  = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-doc-fbr-gds.
      buffer-copy old-doc-fbr-gds to new-doc-fbr-gds.
  end.
end.
if old-trn-doc.ext-doc-type = 'es':U then do:
  for each old-inkas
    where old-inkas.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas.
      buffer-copy old-inkas to new-inkas.
  end.
  for each old-inkas-pay
    where old-inkas-pay.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas-pay.
      buffer-copy old-inkas-pay to new-inkas-pay.
  end.
  for each old-inkas-pay-attr
    where old-inkas-pay-attr.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas-pay-attr.
      buffer-copy old-inkas-pay-attr to new-inkas-pay-attr.
  end.
  for each old-inkas-pay-desk
    where old-inkas-pay-desk.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas-pay-desk.
      buffer-copy old-inkas-pay-desk to new-inkas-pay-desk.
  end.
  for each old-inkas-pay-desk-attr
    where old-inkas-pay-desk-attr.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas-pay-desk-attr.
      buffer-copy old-inkas-pay-desk-attr to new-inkas-pay-desk-attr.
  end.
  for each old-inkas-pay-wth
    where old-inkas-pay-wth.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-inkas-pay-wth.
      buffer-copy old-inkas-pay-wth to new-inkas-pay-wth.
  end.
 if varstay-history  then  for each old-c-inkas
    where old-c-inkas.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-inkas.
      buffer-copy old-c-inkas to new-c-inkas.
  end.
 if varstay-history  then  for each old-c-inkas-pay
    where old-c-inkas-pay.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-inkas-pay.
      buffer-copy old-c-inkas-pay to new-c-inkas-pay.
  end.
  if varstay-history  then for each old-c-inkas-pay-desk
    where old-c-inkas-pay-desk.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-inkas-pay-desk.
      buffer-copy old-c-inkas-pay-desk to new-c-inkas-pay-desk.
  end.
  for each old-c-inkas-pay-wth
    where old-c-inkas-pay-wth.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-inkas-pay-wth.
      buffer-copy old-c-inkas-pay-wth to new-c-inkas-pay-wth.
  end.
  for each old-sale-doc
    where old-sale-doc.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-sale-doc.
      buffer-copy old-sale-doc to new-sale-doc.
  end.
  for each old-sale-doc-attr
    where old-sale-doc-attr.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-sale-doc-attr.
      buffer-copy old-sale-doc-attr to new-sale-doc-attr.
  end.
  if varstay-history  then for each old-c-sale-doc
    where old-c-sale-doc.inkas-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-c-sale-doc.
      buffer-copy old-c-sale-doc to new-c-sale-doc.
  end.
  for each old-chk-doc
    where old-chk-doc.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
    create new-chk-doc.
    buffer-copy old-chk-doc to new-chk-doc.
  end.
  for each old-chk-gds
    where old-chk-gds.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-chk-gds.
      buffer-copy old-chk-gds to new-chk-gds.
  end.
  for each old-chk-pay
    where old-chk-pay.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-chk-pay.
      buffer-copy old-chk-pay to new-chk-pay.
  end.
  for each old-chk-discnt
    where old-chk-discnt.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-chk-discnt.
      buffer-copy old-chk-discnt to new-chk-discnt.
  end.
  for each old-chk-doc-attr
    where old-chk-doc-attr.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-chk-doc-attr.
      buffer-copy old-chk-doc-attr to new-chk-doc-attr.
  end.
  for each old-chk-gds-pay
    where old-chk-gds-pay.out-code = new-trn-doc.doc-code no-lock
  on error undo, return error
  :
      create new-chk-gds-pay.
      buffer-copy old-chk-gds-pay to new-chk-gds-pay.
  end.
  if new-trn-doc.whole-send-news > 0 then do:
    for each old-edi-status where
              old-edi-status.tbl-name = 'trn-doc':U
          and old-edi-status.doc-code = new-trn-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-edi-status.
        buffer-copy old-edi-status to new-edi-status.
    end.
    for each old-edi-status where
              old-edi-status.tbl-name = 'doc-line':U
          and old-edi-status.doc-code begins (new-trn-doc.doc-code + chr(4) )
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-edi-status.
        buffer-copy old-edi-status to new-edi-status.
    end.
  end.
  if varstay-history  then do:
      for each old-c-chk-doc
        where old-c-chk-doc.out-code = new-trn-doc.doc-code no-lock
      on error undo, return error
      :
          create new-c-chk-doc.
          buffer-copy old-c-chk-doc to new-c-chk-doc.
      end.
      for each old-c-chk-gds
        where old-c-chk-gds.out-code = new-trn-doc.doc-code no-lock
      on error undo, return error
      :
          create new-c-chk-gds.
          buffer-copy old-c-chk-gds to new-c-chk-gds.
      end.
      for each old-c-chk-pay
        where old-c-chk-pay.out-code = new-trn-doc.doc-code no-lock
      on error undo, return error
      :
          create new-c-chk-pay.
          buffer-copy old-c-chk-pay to new-c-chk-pay.
      end.
      for each old-c-chk-discnt
        where old-c-chk-discnt.out-code = new-trn-doc.doc-code no-lock
      on error undo, return error
      :
          create new-c-chk-discnt.
          buffer-copy old-c-chk-discnt to new-c-chk-discnt.
      end.
      for each old-c-chk-doc-attr
        where old-c-chk-doc-attr.out-code = new-trn-doc.doc-code no-lock
      on error undo, return error
      :
          create new-chk-doc-attr.
          buffer-copy old-c-chk-doc-attr to new-c-chk-doc-attr.
      end.
  end.
end.
end procedure.
