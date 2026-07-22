block-level on error undo, throw.
/*

$Revision: b1849e93de2b, 967, rls $
$Author: ASMorozov $
$Date: Tue Apr 18 18:36:50 2017 +0300 $
$Workfile: 00007000.p $
$Archive: cut/00007000.p $

Файл пирога обрезания. Относится к категории 7.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
goods
goods-attr
gds-host-attr
gds-obj-attr
c-gds-hist
c-goods
c-goods-attr
c-gds-host-attr
c-gds-obj-attr
bar-code
bar-code-attr
c-bar-code
c-bar-code-attr
bar-code-obj-attr
c-bar-code-obj-attr
prod-bc
c-prod-bc
prod-bc-attr
c-prod-bc-attr
prod-bc-db
prod-bc-db-attr
c-prod-bc-db-attr
code-range
gds-grp
c-gds-grp
gds-grp-attr
c-gds-grp-attr
c-gds-grp-hist
gds-grp-obj
c-gds-grp-obj
gds-grp-obj-attr
gds-prt
gds-prt-attr
c-gds-prt
c-gds-prt-attr
lvl-name
lvl-name-attr
dis-gds-rule
c-dis-gds-rule
dis-gds-rule-attr
c-dis-gds-rule-attr
dis-grp-rule -  частично
c-dis-grp-rule -  частично
dis-grp-rule-attr -  частично
ext-classif -  частично
ext-classif-attr -  частично
c-ext-classif -  частично
*/

define variable vss-revision    as character no-undo init "$Revision: b1849e93de2b, 967, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 18 18:36:50 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00007000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00007000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 7.".
define buffer old-goods           for src.goods.
define buffer new-goods           for dst.goods.
define buffer old-goods-attr      for src.goods-attr.
define buffer new-goods-attr      for dst.goods-attr.
define buffer old-c-goods-attr    for src.c-goods-attr.
define buffer new-c-goods-attr    for dst.c-goods-attr.
define buffer old-gds-host-attr   for src.gds-host-attr.
define buffer new-gds-host-attr   for dst.gds-host-attr.
define buffer old-c-gds-host-attr for src.c-gds-host-attr.
define buffer new-c-gds-host-attr for dst.c-gds-host-attr.
define buffer old-gds-obj-attr    for src.gds-obj-attr.
define buffer new-gds-obj-attr    for dst.gds-obj-attr.
define buffer old-c-gds-obj-attr  for src.c-gds-obj-attr.
define buffer new-c-gds-obj-attr  for dst.c-gds-obj-attr.
define buffer old-c-gds-hist      for src.c-gds-hist.
define buffer new-c-gds-hist      for dst.c-gds-hist.
define buffer old-c-goods         for src.c-goods.
define buffer new-c-goods         for dst.c-goods.
define buffer old-bar-code        for src.bar-code.
define buffer new-bar-code        for dst.bar-code.
define buffer old-c-bar-code      for src.c-bar-code.
define buffer new-c-bar-code      for dst.c-bar-code.
define buffer old-bar-code-attr   for src.bar-code-attr.
define buffer new-bar-code-attr   for dst.bar-code-attr.
define buffer old-c-bar-code-attr for src.c-bar-code-attr.
define buffer new-c-bar-code-attr for dst.c-bar-code-attr.
define buffer old-bar-code-obj-attr   for src.bar-code-obj-attr.
define buffer new-bar-code-obj-attr   for dst.bar-code-obj-attr.
define buffer old-c-bar-code-obj-attr for src.c-bar-code-obj-attr.
define buffer new-c-bar-code-obj-attr for dst.c-bar-code-obj-attr.
define buffer old-prod-bc         for src.prod-bc.
define buffer new-prod-bc         for dst.prod-bc.
define buffer old-c-prod-bc       for src.c-prod-bc.
define buffer new-c-prod-bc       for dst.c-prod-bc.
define buffer old-prod-bc-attr    for src.prod-bc-attr.
define buffer new-prod-bc-attr    for dst.prod-bc-attr.
define buffer old-c-prod-bc-attr  for src.c-prod-bc-attr.
define buffer new-c-prod-bc-attr  for dst.c-prod-bc-attr.
define buffer old-prod-bc-db      for src.prod-bc-db.
define buffer new-prod-bc-db      for dst.prod-bc-db.
define buffer old-prod-bc-db-attr for src.prod-bc-db-attr.
define buffer new-prod-bc-db-attr for dst.prod-bc-db-attr.
define buffer old-c-prod-bc-db-attr for src.c-prod-bc-db-attr.
define buffer new-c-prod-bc-db-attr for dst.c-prod-bc-db-attr.
define buffer old-code-range      for src.code-range.
define buffer new-code-range      for dst.code-range.
define buffer old-gds-grp         for src.gds-grp.
define buffer new-gds-grp         for dst.gds-grp.
define buffer old-c-gds-grp       for src.c-gds-grp.
define buffer new-c-gds-grp       for dst.c-gds-grp.
define buffer old-gds-grp-obj     for src.gds-grp-obj.
define buffer new-gds-grp-obj     for dst.gds-grp-obj.
define buffer old-c-gds-grp-obj   for src.c-gds-grp-obj.
define buffer new-c-gds-grp-obj   for dst.c-gds-grp-obj.
define buffer old-gds-grp-obj-attr for src.gds-grp-obj-attr.
define buffer new-gds-grp-obj-attr for dst.gds-grp-obj-attr.
define buffer old-gds-grp-attr    for src.gds-grp-attr.
define buffer new-gds-grp-attr    for dst.gds-grp-attr.
define buffer old-c-gds-grp-attr  for src.c-gds-grp-attr.
define buffer new-c-gds-grp-attr  for dst.c-gds-grp-attr.
define buffer old-c-gds-grp-hist  for src.c-gds-grp-hist.
define buffer new-c-gds-grp-hist  for dst.c-gds-grp-hist.
define buffer old-gds-prt         for src.gds-prt.
define buffer new-gds-prt         for dst.gds-prt.
define buffer old-c-gds-prt       for src.c-gds-prt.
define buffer new-c-gds-prt       for dst.c-gds-prt.
define buffer old-gds-prt-attr    for src.gds-prt-attr.
define buffer new-gds-prt-attr    for dst.gds-prt-attr.
define buffer old-c-gds-prt-attr  for src.c-gds-prt-attr.
define buffer new-c-gds-prt-attr  for dst.c-gds-prt-attr.
define buffer old-lvl-name        for src.lvl-name.
define buffer new-lvl-name        for dst.lvl-name.
define buffer old-lvl-name-attr   for src.lvl-name-attr.
define buffer new-lvl-name-attr   for dst.lvl-name-attr.
define buffer old-parts           for dst.parts.
define buffer old-gds-obj         for src.gds-obj.
define buffer old-prt-obj         for src.prt-obj.
define buffer old-doc-line        for src.doc-line.
define buffer old-rvs-line        for src.rvs-line.
define buffer old-rvs-doc         for src.rvs-doc.
define buffer old-ord-line        for src.ord-line.
define buffer old-c-ord-line      for src.c-ord-line.
define buffer old-ord-doc         for src.ord-doc.
define buffer old-c-ord-doc       for src.c-ord-doc.
define buffer old-ord-line-rcv    for src.ord-line-rcv.
define buffer old-ord-doc-rcv     for src.ord-doc-rcv.
define buffer old-fbr-line        for src.fbr-line.
define buffer old-fbr-doc         for src.fbr-doc.
define buffer old-c-doc-line      for src.c-doc-line.
define buffer old-c-trn-doc       for src.c-trn-doc.
define buffer old-c-price-list    for src.c-price-list.
define buffer old-c-price-doc     for src.c-price-doc.
define buffer old-c-rvs-line      for src.c-rvs-line.
define buffer old-c-rvs-doc       for src.c-rvs-doc.
define buffer old-c-fbr-line      for src.c-fbr-line.
define buffer old-c-fbr-doc       for src.c-fbr-doc.
define buffer old-inkas           for src.inkas.
define buffer old-chk-gds         for src.chk-gds.
define buffer old-place           for src.place.
define buffer old-units           for src.units.
define buffer old-recipe          for src.recipe.
define buffer old-recipe-gds      for src.recipe-gds.
define buffer old-clients         for src.clients.
define buffer old-price-list      for src.price-list.
define buffer old-price-doc       for src.price-doc.
define buffer old-c-cd-doc        for src.c-cd-doc.
define buffer old-cd-doc          for src.cd-doc.
define buffer old-c-cd-doc-line   for src.c-cd-doc-line.
define buffer old-cd-doc-line     for src.cd-doc-line.
define buffer old_db              for src.db.
define buffer old-icnt-doc        for src.icnt-doc.
define buffer old-icnt-line       for src.icnt-line.
define buffer old-contract-specif for src.contract-specif.
define buffer old-dis-gds-rule    for src.dis-gds-rule.
define buffer new-dis-gds-rule    for dst.dis-gds-rule.
define buffer old-c-dis-gds-rule  for src.c-dis-gds-rule.
define buffer new-c-dis-gds-rule  for dst.c-dis-gds-rule.
define buffer old-dis-gds-rule-attr for src.dis-gds-rule-attr.
define buffer new-dis-gds-rule-attr for dst.dis-gds-rule-attr.
define buffer old-dis-grp-rule    for src.dis-grp-rule.
define buffer new-dis-grp-rule    for dst.dis-grp-rule.
define buffer old-c-dis-grp-rule  for src.c-dis-grp-rule.
define buffer new-c-dis-grp-rule  for dst.c-dis-grp-rule.
define buffer old-dis-grp-rule-attr for src.dis-grp-rule-attr.
define buffer new-dis-grp-rule-attr for dst.dis-grp-rule-attr.
define buffer old-ext-classif         for src.ext-classif.
define buffer new-ext-classif         for dst.ext-classif.
define buffer old-ext-classif-attr    for src.ext-classif-attr.
define buffer new-ext-classif-attr    for dst.ext-classif-attr.
define buffer old-c-ext-classif       for src.c-ext-classif.
define buffer new-c-ext-classif       for dst.c-ext-classif.
define buffer old-wth-gds             for src.wth-gds.



define variable varactual-goods  as logical no-undo.
define variable varin-date       as date    no-undo.
define variable varlast-date     as date    no-undo.
define variable i                as integer no-undo.
define variable varwrite-to-file as logical no-undo.
define variable var-date-docs    as date    no-undo .
define variable var-fact-order-docs as decimal no-undo .
define variable l-is-empty-scale as logical no-undo .

define stream LogStream.


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/key-rec.i  }
{ ref/grp-attr.i }
{ ref/extclass.i }

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.c-gds-hist override do: end.
on WRITE of dst.goods      override do: end.
on WRITE of dst.c-goods    override do: end.
on WRITE of dst.goods-attr override do: end.
on WRITE of dst.c-goods-attr override do: end.
on WRITE of dst.gds-host-attr override do: end.
on WRITE of dst.c-gds-host-attr override do: end.
on WRITE of dst.gds-obj-attr override do: end.
on WRITE of dst.c-gds-obj-attr override do: end.
on WRITE of dst.bar-code   override do: end.
on WRITE of dst.bar-code-attr   override do: end.
on WRITE of dst.c-bar-code override do: end.
on WRITE of dst.c-bar-code-attr override do: end.
on WRITE of dst.bar-code-obj-attr   override do: end.
on WRITE of dst.c-bar-code-obj-attr   override do: end.
on WRITE of dst.prod-bc    override do: end.
on WRITE of dst.c-prod-bc  override do: end.
on WRITE of dst.prod-bc-attr override do: end.
on WRITE of dst.c-prod-bc-attr override do: end.
on WRITE of dst.prod-bc-db    override do: end.
on WRITE of dst.prod-bc-db-attr    override do: end.
on WRITE of dst.c-prod-bc-db-attr  override do: end.
on WRITE of dst.code-range override do: end.
on WRITE of dst.gds-grp    override do: end.
on WRITE of dst.gds-grp-obj    override do: end.
on WRITE of dst.c-gds-grp  override do: end.
on WRITE of dst.c-gds-grp-obj  override do: end.
on WRITE of dst.gds-grp-obj-attr override do: end.
on WRITE of dst.gds-grp-attr    override do: end.
on WRITE of dst.c-gds-grp-attr  override do: end.
on WRITE of dst.c-gds-grp-hist  override do: end.
on WRITE of dst.gds-prt    override do: end.
on WRITE of dst.c-gds-prt    override do: end.
on WRITE of dst.gds-prt-attr    override do: end.
on WRITE of dst.c-gds-prt-attr  override do: end.
on WRITE of dst.lvl-name   override do: end.
on WRITE of dst.lvl-name-attr   override do: end.
on WRITE of dst.dis-gds-rule   override do: end.
on WRITE of dst.dis-gds-rule-attr   override do: end.
on WRITE of dst.c-dis-gds-rule override do: end.
on WRITE of dst.dis-grp-rule   override do: end.
on WRITE of dst.c-dis-grp-rule   override do: end.
on WRITE of dst.dis-grp-rule-attr   override do: end.
on WRITE of dst.ext-classif   override do: end.
on WRITE of dst.ext-classif-attr override do: end.
on WRITE of dst.c-ext-classif override do: end.


/*поскольку у нас нет index в c-fbr-doc ни по fact-date ни по doc-date придется построить верм табл */

define temp-table temp-c-fbr-line no-undo
field artic      like src.c-fbr-line.artic
field prod-type  like src.c-fbr-line.prod-type
field prod-code  like src.c-fbr-line.prod-code
field fact-date  like src.c-fbr-doc.fact-date
index pi is unique primary
fact-date
artic
prod-type
prod-code
.

/*для тех товаров которых нет в продаже но есть в чеке тоже придется врем таблицу соорудить*/

define temp-table temp-chk-gds no-undo
field gds-code  like src.goods.gds-code
field b-code    like src.chk-gds.b-code
field fact-date like src.inkas.fact-date
index pi is unique primary
fact-date
b-code
index igdscode
fact-date
gds-code
.



if vardate-actual-goods <> ? then do:
  if vartype-cut = 0 then do:
    for each old-c-fbr-doc no-lock:
      if old-c-fbr-doc.fact-date >= vardate-actual-goods then do:
        for each old-c-fbr-line where
                old-c-fbr-line.doc-code = old-c-fbr-doc.doc-code
            AND old-c-fbr-line.chip-num = old-c-fbr-doc.chip-num on error undo, return error return-value :
          find first temp-c-fbr-line where
                    temp-c-fbr-line.fact-date = old-c-fbr-doc.fact-date
                AND temp-c-fbr-line.artic    = old-c-fbr-line.artic
                AND temp-c-fbr-line.prod-type = old-c-fbr-line.prod-type
                AND temp-c-fbr-line.prod-code = old-c-fbr-line.prod-code no-error .
          if not available temp-c-fbr-line then do:
            create temp-c-fbr-line.
            buffer-copy
            old-c-fbr-line to temp-c-fbr-line
            assign
            temp-c-fbr-line.fact-date = old-c-fbr-doc.fact-date
            .
          end.
        end. /*for each old-c-fbr-line where*/
      end. /*if old-c-fbr-doc.fact-date >= vardate-actual-goods then do:*/
    end. /*for each old-c-fbr-doc no-lock:*/

    for each old_db
    ,each old-clients no-lock
      where old-clients.db-num = old_db.db-num,
      each old-inkas no-lock where
          old-inkas.obj-type = old-clients.obj-type
      AND old-inkas.obj-code = old-clients.obj-code
      AND old-inkas.status_  = {&Fact}
      AND old-inkas.doc-date >= vardate-actual-goods
      on error undo, return error:
      for each old-chk-gds no-lock where
                  old-chk-gds.out-code = old-inkas.inkas-code:
        if old-chk-gds.line-sign = ?
        or old-chk-gds.line-sign = no then do:
          find first temp-chk-gds no-lock where
                      temp-chk-gds.fact-date = old-inkas.fact-date
                  and temp-chk-gds.b-code    = old-chk-gds.b-code no-error .
          if not available temp-chk-gds then do:
            find first old-bar-code no-lock where
                      old-bar-code.b-code = old-chk-gds.b-code no-error .
            if not available old-bar-code then do:
                return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            end.
            create temp-chk-gds.
            assign
            temp-chk-gds.fact-date = old-inkas.fact-date
            temp-chk-gds.b-code    = old-chk-gds.b-code
            temp-chk-gds.gds-code  = old-bar-code.gds-code
            .
          end. /*if not available temp-chk-gds then do:*/
        end. /* if old-chk-gds.line-sign = ?*/
      end. /*for each old-chk-gds no-lock where*/
    end. /*for each old_db*/
  end. /*if vartype-cut = 0 then do:*/

  /*Перегрузка goods*/
  for each old-goods no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if vartype-cut = 1 then do:
      /*при vartype-cut = 1 СПРАВОЧНИКИ ВЫГРУЖАЮТСЯ ЦЕЛИКОМ*/
      assign
      varactual-goods = true.
    end.
    if vartype-cut = 0 then do:
      /*все проверки нужны если у нас старый тип обрезания - с обрезанием справочником*/
      assign
      varactual-goods  = false
      varwrite-to-file = false
      .
      /*Если оставляем все весовые товары*/
      if varstay-weight-goods then do:
        find old-units where old-units.unit-name = old-goods.unit-base no-lock.
        wt:
        do i = 1 to num-entries(old-units.type):
          if entry(i, old-units.type) = {&weight} then do:
            assign
              varactual-goods = true
            .
            leave wt.
          end.
        end. /*do i = 1 to num-entries*/
      end. /*if varstay-weight-goods then do:*/
      /*Если оставляем все товары для рецептов*/
      if varstay-recipe-goods = true
      then do:
        find first old-recipe no-lock
              where old-recipe.artic     = old-goods.artic
                and old-recipe.prod-type = old-goods.prod-type
                and old-recipe.prod-code = old-goods.prod-code
        no-error.
        if available old-recipe
        then do:
            assign
                varactual-goods = true
            .
        end.
        else do:
            find first old-recipe-gds no-lock
                 where old-recipe-gds.artic     = old-goods.artic
                   and old-recipe-gds.prod-type = old-goods.prod-type
                   and old-recipe-gds.prod-code = old-goods.prod-code
            no-error.
            if available old-recipe-gds
            then do:
                assign
                    varactual-goods = true
                .
            end.
        end.
      end. /*if varstay-recipe-goods = true*/

      if varactual-goods = false then do:
        /* Если есть остаток на каком-либо объекте, то товар надо оставить даже если нет документов.
          Исключение - удаленные товары (stts <> 0 ).
          Так как могли вычистить документы обрезанием.*/
        /*если шкальный должны еще искать по prt-obj*/
        { gbl/gdscdat.i old-goods.gds-code  'empty-scale=request' l-is-empty-scale }
        old-gds-obj:
        for each old-gds-obj no-lock
          where old-gds-obj.gds-code     = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-gds-obj.fact-qnty <> 0
          or old-gds-obj.avrg-qnty <> 0
          or old-gds-obj.in-date   >= vardate-actual-goods
          then do:
            if old-goods.stts <> 0
              and varnot-copy-del-goods
            then do:
              assign
                varwrite-to-file = true
              .
            end.
            else do:
              assign
                varactual-goods = true
              .
            end.
            if varactual-goods = false
            and  l-is-empty-scale = false then do:
              _prt-obj:
              for each old-prt-obj no-lock where
                      old-prt-obj.obj-type = old-gds-obj.obj-type
                  and old-prt-obj.obj-code = old-gds-obj.obj-code
                  and old-prt-obj.artic    = old-gds-obj.artic
                  and old-prt-obj.prod-type    = old-gds-obj.prod-type
                  and old-prt-obj.prod-code    = old-gds-obj.prod-code
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
              :
                if not old-prt-obj.is-term then next.
                if old-prt-obj.fact-qnty <> 0
                or old-prt-obj.free-qnty <> 0
                then do:
                  if old-goods.stts <> 0
                    and varnot-copy-del-goods
                  then do:
                    assign
                      varwrite-to-file = true
                    .
                  end.
                  else do:
                    assign
                      varactual-goods = true
                    .
                  end.
                  leave old-gds-obj.
                end.  /*if old-prt-obj.fact-qnty <> 0*/
              end. /*for each each old-prt-obj no-lock where*/
            end. /*if varactual-goods = false*/
            leave old-gds-obj.
          end. /*if old-gds-obj.fact-qnty    <> 0*/
        end. /*each old-gds-obj*/
      end.
      if varactual-goods = false then do:
          if old-goods.stts <> 0
             and varnot-copy-del-goods = true
          then do:
            assign
              var-date-docs = vardate-actual-docs
            .
          end.
          else do:
            assign
              var-date-docs = vardate-actual-goods
            .
          end.
          run factord-end-day in this-procedure ( var-date-docs - 1, output var-fact-order-docs).
          old-clients :
          /* обработать все объекты (включая удаленные) */
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
              find last old-doc-line where old-doc-line.obj-type   = old-clients.obj-type and
                                           old-doc-line.obj-code   = old-clients.obj-code and
                                           old-doc-line.prod-type  = old-goods.prod-type  and
                                           old-doc-line.prod-code  = old-goods.prod-code  and
                                           old-doc-line.artic      = old-goods.artic      and
                                           old-doc-line.status_    = {&fact}
                                           use-index fact-order no-lock no-error.
              if available old-doc-line                         and
                old-doc-line.fact-order >= var-fact-order-docs then do:
                assign
                  varactual-goods = true
                .
                leave old-clients.
              end. /*available old-doc-line*/
          end.  /*for each old_db*/
        end.  /*Восстановление товаров по документам*/
        /*восстановление по партиям свободной зоны и зарезерв*/
        if varactual-goods = false then do:
          old-clients-parts-free :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            for each old-parts no-lock where
                    old-parts.obj-type  = old-clients.obj-type
                and old-parts.obj-code  = old-clients.obj-code
                and old-parts.artic     = old-goods.artic
                and old-parts.prod-type = old-goods.prod-type
                and old-parts.prod-code = old-goods.prod-code
                and old-parts.status_   = no
                and old-parts.rsrv-free = yes
                and old-parts.in-code   <> old-parts.out-code
            on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              assign
                varactual-goods = true
              .
              leave old-clients-parts-free.
            end.
          end. /* for each old_db */
        end. /*Восстановление товаров по партиям свободной зоны*/
        /*по icnt-line*/
        if varactual-goods = false then do:
          old_icnt-line:
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            _icnt-line:
            for each old-icnt-line no-lock where
                    old-icnt-line.gds-code = old-goods.gds-code,
              first old-icnt-doc no-lock where
                  old-icnt-doc.obj-type = old-clients.obj-type
              and old-icnt-doc.obj-code = old-clients.obj-code
              and old-icnt-doc.doc-code = old-icnt-line.doc-code
              and old-icnt-doc.doc-date >= var-date-docs
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              assign
              varactual-goods = yes.
              leave old_icnt-line.
            end.
          end.
        end.
        /*Переоценки будут считать, что все товары по ним существуют.
          Проверяем ситуацию когда по товару нет документов, но есть переоценки.*/
        if varactual-goods = false then do:
          old-clients-price :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            find old-gds-prt no-lock
            where old-gds-prt.upper-code = old-goods.prt-root
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            find first  old-bar-code no-lock
            where old-bar-code.gds-code  = old-goods.gds-code
              and old-bar-code.node-code = old-gds-prt.node-code
              and old-bar-code.part-code = ""
              and old-bar-code.in-code   = ""
              and old-bar-code.unit-cli  = old-goods.unit-base
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            for each old-price-list where old-price-list.obj-type   =  old-clients.obj-type and
                                          old-price-list.obj-code   =  old-clients.obj-code and
                                          old-price-list.price-type =  ""                   and
                                          old-price-list.fact-order >= var-fact-order-docs  and
                                          old-price-list.b-code     =  old-bar-code.b-code  no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-clients-price.
            end. /* for each old-price-list */
          end. /* for each old_db */
        end. /*Восстановление товаров по переоценкам*/
        if varactual-goods = false then do:
          old-rvs-doc :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num on error undo, return error return-value :
            for each old-rvs-line where old-rvs-line.obj-type = old-clients.obj-type and
                                        old-rvs-line.obj-code = old-clients.obj-code and
                                        old-rvs-line.gds-code = old-goods.gds-code   no-lock,
                first old-rvs-doc where old-rvs-doc.rvs-code    = old-rvs-line.rvs-code and
                                        old-rvs-doc.fact-order >= var-fact-order-docs   on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-rvs-doc.
            end.
          end. /*  for each old_db*/
        end. /*Восстановление товаров по сверкам*/
        if varactual-goods = false then do:
          old-ord-doc :
          for each old_db
            ,each old-clients no-lock
              where old-clients.db-num = old_db.db-num
            on error undo, return error
            :
            for each old-ord-doc where old-ord-doc.obj-type    = old-clients.obj-type and
                                       old-ord-doc.obj-code    = old-clients.obj-code and
                                       old-ord-doc.status_     = {&fact}              and
                                       old-ord-doc.fact-order >= var-fact-order-docs  no-lock,
              first old-ord-line where  old-ord-line.prod-type = old-goods.prod-type  and
                                        old-ord-line.prod-code = old-goods.prod-code  and
                                        old-ord-line.artic     = old-goods.artic      and
                                        old-ord-line.doc-code  = old-ord-doc.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-ord-doc.
            end.
          end. /*for each old_db*/
        end. /*Восстановление товаров по заказам*/
        if varactual-goods = false then do:
            old-ord-doc-rcv :
            for each old_db
          ,each old-clients no-lock
            where old-clients.db-num = old_db.db-num
          on error undo, return error
          :
            for each old-ord-doc-rcv where old-ord-doc-rcv.obj-type    = old-clients.obj-type and
                                           old-ord-doc-rcv.obj-code    = old-clients.obj-code and
                                           old-ord-doc-rcv.status_     = {&fact}              and
                                           old-ord-doc-rcv.fact-order >= var-fact-order-docs  no-lock,
              first old-ord-line-rcv where  old-ord-line-rcv.artic     = old-goods.artic          and
                                            old-ord-line-rcv.prod-type = old-goods.prod-type      and
                                            old-ord-line-rcv.prod-code = old-goods.prod-code      and
                                            old-ord-line-rcv.doc-code  = old-ord-doc-rcv.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-ord-doc-rcv.
            end.
          end.
        end. /*Восстановление товаров по поставкам*/
        if varactual-goods = false then do:
            old-fbr-doc :
          for each old_db
           ,each old-clients no-lock where old-clients.db-num = old_db.db-num on error undo, return error return-value :
            for each old-fbr-doc where old-fbr-doc.obj-type   = old-clients.obj-type and
                                       old-fbr-doc.obj-code   = old-clients.obj-code and
                                       old-fbr-doc.status_    = {&fact}              and
                                       old-fbr-doc.fact-date >= var-date-docs        no-lock,
              first old-fbr-line where  old-fbr-line.prod-type = old-goods.prod-type      and
                                        old-fbr-line.prod-code = old-goods.prod-code      and
                                        old-fbr-line.artic     = old-goods.artic          and
                                        old-fbr-line.doc-code  = old-ord-doc-rcv.doc-code no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-fbr-doc.
            end.
          end.
        end. /*Восстановление товаров по производству*/
        if varactual-goods = false then do:
            old-c-trn-doc :
            for each old_db
          ,each old-clients no-lock
            where old-clients.db-num = old_db.db-num
          on error undo, return error
          :
            for each old-c-trn-doc where old-c-trn-doc.obj-type   = old-clients.obj-type and
                                         old-c-trn-doc.obj-code   = old-clients.obj-code and
                                         old-c-trn-doc.status_    = {&fact}              and
                                          old-c-trn-doc.doc-date >= var-date-docs        no-lock,
              first old-c-doc-line where old-c-doc-line.doc-code  = old-c-trn-doc.doc-code AND
                                         old-c-doc-line.chip-num  = old-c-trn-doc.chip-num AND
                                         old-c-doc-line.artic     = old-goods.artic        and
                                         old-c-doc-line.prod-type = old-goods.prod-type    and
                                         old-c-doc-line.prod-code = old-goods.prod-code    no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-c-trn-doc.
            end.
          end.
        end. /*Восстановление товаров по истории документов*/
        if varactual-goods = false then do:
          old-c-price-doc :
          for each old_db
        ,each old-clients no-lock
          where old-clients.db-num = old_db.db-num
        on error undo, return error
        :
            find old-gds-prt no-lock
            where old-gds-prt.upper-code = old-goods.prt-root
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            find first  old-bar-code no-lock
            where old-bar-code.gds-code  = old-goods.gds-code
              and old-bar-code.node-code = old-gds-prt.node-code
              and old-bar-code.part-code = "":u
              and old-bar-code.in-code   = "":u
              and old-bar-code.unit-cli  = old-goods.unit-base
            no-error .
            if error-status :error then return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) .
            for each old-c-price-doc where old-c-price-doc.obj-type    = old-clients.obj-type and
                                           old-c-price-doc.obj-code    = old-clients.obj-code and
                                           old-c-price-doc.status_     = {&fact}              and
                                           old-c-price-doc.fact-order   >= var-fact-order-docs  no-lock,
              first old-c-price-list where old-c-price-list.doc-num    = old-c-price-doc.doc-num  and
                                           old-c-price-list.chip-num   = old-c-price-doc.chip-num and
                                           old-c-price-list.price-type = "":u                     and
                                           old-c-price-list.b-code     = old-bar-code.b-code      no-lock on error undo, return error return-value :
              assign
                varactual-goods = true
              .
              leave old-c-price-doc.
            end.
          end.
        end. /*Восстановление товаров по истории прайслист*/
        if varactual-goods = false then do:
          old-c-rvs-doc :
          for each old_db
        ,each old-clients no-lock
          where old-clients.db-num = old_db.db-num
        on error undo, return error
        :
            for each old-c-rvs-doc where old-c-rvs-doc.obj-type    = old-clients.obj-type and
                                         old-c-rvs-doc.obj-code    = old-clients.obj-code and
                                         old-c-rvs-doc.status_     = {&fact}              and
                                         old-c-rvs-doc.fact-order >= var-fact-order-docs  no-lock,
                first old-c-rvs-line where old-c-rvs-line.rvs-code = old-c-rvs-doc.rvs-code AND
                                          old-c-rvs-line.chip-num = old-c-rvs-doc.chip-num  AND
                                          old-c-rvs-line.gds-code  = old-goods.gds-code no-lock:
                assign
                  varactual-goods = true
                .
                leave old-c-rvs-doc.
            end.
          end. /*  */
        end. /*Восстановление товаров по истории сверок*/
        if varactual-goods = false then do: /*Восстановление товаров по истории производства*/
          old-c-fbr-doc :
          for each temp-c-fbr-line where temp-c-fbr-line.fact-date >= var-date-docs       and
                                         temp-c-fbr-line.artic      = old-goods.artic     and
                                         temp-c-fbr-line.prod-type  = old-goods.prod-type and
                                         temp-c-fbr-line.prod-code  = old-goods.prod-code no-lock
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave old-c-fbr-doc.
          end.
        end. /*Восстановление товаров по истории производства*/
        if varactual-goods = false then do:
          find first old-contract-specif where old-contract-specif.gds-code = old-goods.gds-code no-error .
          if available old-contract-specif then assign varactual-goods = true .
        end. /*Восстановление товаров по спецификациям к договорам*/
        /*Восстановление товаров по строкам чеков не вошешим в продажи*/
        if varactual-goods = false then do:
          old-chk-gds :
          for each temp-chk-gds no-lock where
                   temp-chk-gds.fact-date  > var-date-docs
               and temp-chk-gds.gds-code   = old-goods.gds-code
            on error undo, return error
            :
                assign
                  varactual-goods = true
                .
                leave old-chk-gds.
          end.
        end. /*Восстановление товаров по строкам чеков не вошешим в продажи*/
        if varactual-goods = false then do: /*Восстановление товаров по талонным товарам*/
          old-wth-gds :
          for each old-wth-gds where old-wth-gds.gds-code = old-goods.gds-code
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave old-wth-gds.
          end.
        end. /*Восстановление товаров по талонным товарам*/
        if varactual-goods = false then do: /*Восстановление товаров по группам с нетоварными позициями*/
          gds-grp-attr :
          for each old-gds-grp-attr where
                   old-gds-grp-attr.node-code = old-goods.grp-code      and
                   old-gds-grp-attr.attr-code = {&attr-gds-grp-nabor-h} and
                   old-gds-grp-attr.attr-value = "yes"  and
                   old-gds-grp-attr.host-code = 0  and
                   old-gds-grp-attr.obj-code  = 0  and
                   old-gds-grp-attr.obj-type  = ""
          on error undo, return error return-value
          :
            assign
              varactual-goods = true
            .
            leave gds-grp-attr.
          end.
        end. /*Восстановление товаров по группам с нетоварными позициями*/


       /*Восстановление товаров по истории заказов ОТКЛЮЧЕНО ИЗ-ЗА ОТСУТСТВИЯ ИНДЕКСА*/
      /*
      if varactual-goods = false then do:
        old-ord-doc :
        for each old_db
          ,each old-clients no-lock
            where old-clients.db-num = old_db.db-num
          on error undo, return error
          :
          for each old-c-ord-doc where
                  old-c-ord-doc.obj-type    = old-clients.obj-type
              and old-c-ord-doc.obj-code    = old-clients.obj-code
              and old-c-ord-doc.status_     = {&fact}
              and old-c-ord-doc.fact-c-order >= var-fact-c-order-docs  no-lock,
              each old-c-ord-line where
                  old-c-ord-line.prod-type = old-goods.prod-type
              and old-c-ord-line.prod-code = old-goods.prod-code
              and old-c-ord-line.artic     = old-goods.artic
              and old-c-ord-line.doc-code   = old-c-ord-doc.doc-code no-lock on error undo, return error return-value :
            assign
              varactual-goods = true
            .
            leave old-ord-doc.
          end.
        end.
      end. */
      /*   end-of Восстановление товаров по истории заказов*/
        old-c-cd-doc :
        for each old_db
      ,each old-clients no-lock
        where old-clients.db-num = old_db.db-num
      on error undo, return error  :
         for each old-c-cd-doc no-lock where
                 old-c-cd-doc.obj-type   = old-clients.obj-type
             and old-c-cd-doc.obj-code   = old-clients.obj-code,
          first old-c-cd-doc-line where
               old-c-cd-doc-line.obj-type  = old-c-cd-doc.obj-type
            and old-c-cd-doc-line.obj-code  = old-c-cd-doc.obj-code
            and old-c-cd-doc-line.pos-type  = old-c-cd-doc.pos-type
            and old-c-cd-doc-line.doc-type  = old-c-cd-doc.doc-type
            and old-c-cd-doc-line.doc-code  = old-c-cd-doc.doc-code
            and old-c-cd-doc-line.corr-user-db-num  = old-c-cd-doc.corr-user-db-num
            and old-c-cd-doc-line.chip-num  = old-c-cd-doc.chip-num
            and old-c-cd-doc-line.gds-code  = old-goods.gds-code
            no-lock on error undo, return error return-value :
          if old-c-cd-doc.datekey_one >= var-date-docs     and
          old-c-cd-doc.is-del = yes  then do:
            assign
              varactual-goods = true
            .
            leave old-c-cd-doc.
          end.
        end.
      end.
        old-cd-doc :
        for each old_db
      ,each old-clients no-lock
        where old-clients.db-num = old_db.db-num
      on error undo, return error  :
         for each old-cd-doc no-lock where
                 old-cd-doc.obj-type   = old-clients.obj-type
             and old-cd-doc.obj-code   = old-clients.obj-code,
          first old-cd-doc-line where
               old-cd-doc-line.obj-type  = old-cd-doc.obj-type
            and old-cd-doc-line.obj-code  = old-cd-doc.obj-code
            and old-cd-doc-line.pos-type  = old-cd-doc.pos-type
            and old-cd-doc-line.doc-type  = old-cd-doc.doc-type
            and old-cd-doc-line.doc-code  = old-cd-doc.doc-code
            and old-cd-doc-line.gds-code  = old-goods.gds-code
          no-lock on error undo, return error return-value :
          if old-cd-doc.datekey_one >= var-date-docs  then do:
            assign
              varactual-goods = true
            .
            leave old-cd-doc.
          end.
        end.
      end.
    end. /*if vartype-cut = 0*/
    if varactual-goods = true then do:
      do transaction
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
      create new-goods.
      buffer-copy old-goods to new-goods.
      end.
      for each old-goods-attr no-lock where
              old-goods-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-goods-attr.
        buffer-copy old-goods-attr to new-goods-attr.
      end.
      for each old-gds-obj-attr no-lock where
              old-gds-obj-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-gds-obj-attr.
        buffer-copy old-gds-obj-attr to new-gds-obj-attr.
      end.
      for each old-gds-host-attr no-lock where
              old-gds-host-attr.gds-code = old-goods.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-gds-host-attr.
        buffer-copy old-gds-host-attr to new-gds-host-attr.
      end.
      if varstay-history then do:
        for each old-c-gds-hist no-lock where
                old-c-gds-hist.gds-code = old-goods.gds-code
            on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-hist.
          buffer-copy old-c-gds-hist to new-c-gds-hist.
        end.
        for each old-c-goods no-lock where
                old-c-goods.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-goods.
          buffer-copy old-c-goods to new-c-goods.
        end.
        for each old-c-goods-attr no-lock where
                old-c-goods-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-goods-attr.
          buffer-copy old-c-goods-attr to new-c-goods-attr.
        end.
        for each old-c-gds-host-attr no-lock where
                old-c-gds-host-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-host-attr.
          buffer-copy old-c-gds-host-attr to new-c-gds-host-attr.
        end.
        for each old-c-gds-obj-attr no-lock where
                old-c-gds-obj-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-gds-obj-attr.
          buffer-copy old-c-gds-obj-attr to new-c-gds-obj-attr.
        end.
        for each old-c-bar-code-obj-attr no-lock where
                old-c-bar-code-obj-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-obj-attr.
          buffer-copy old-c-bar-code-obj-attr to new-c-bar-code-obj-attr.
        end.
        for each old-c-bar-code-attr no-lock where
                old-c-bar-code-attr.gds-code = old-goods.gds-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-attr.
          buffer-copy old-c-bar-code-attr to new-c-bar-code-attr.
        end.
      end. /*if varstay-history then do:*/
    end.
    else do:
      if varwrite-to-file = true then do:
        output stream LogStream to "del-gds.txt" append.
        put stream LogStream unformatted
        "Артикул:" {&space-char} old-goods.artic {&space-char}
        "Производитель:" {&space-char} old-goods.prod-code {&space-char} old-goods.prod-type {&space-char}
        "Название:" {&space-char} old-goods.gds-name
        skip
        .
        output stream LogStream close.
      end.
    end.
  end. /*each old-goods*/

  for each old-bar-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-goods where new-goods.gds-code  = old-bar-code.gds-code no-lock no-error.
    if available new-goods then do:
      create new-bar-code.
      buffer-copy old-bar-code to new-bar-code.
      if varstay-history then do:
        for each old-c-bar-code no-lock where
                old-c-bar-code.b-code = new-bar-code.b-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code.
          buffer-copy old-c-bar-code to new-c-bar-code.
        end.
      end. /*if varstay-history then do:*/
    end.
    else do:
      /*
      find first old-place where old-place.pl-code = int(old-bar-code.b-code) no-lock no-error.
      if available old-place then do:
          create new-bar-code.
          buffer-copy old-bar-code to new-bar-code.
      end.
      а bar-code для place НЕ СОЗДАЮТСЯ!!!!!
      */
    end.
  end.
  for each old-bar-code-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-goods where new-goods.gds-code  = old-bar-code-attr.gds-code no-lock no-error.
    if available new-goods then do:
      create new-bar-code-attr.
      buffer-copy old-bar-code-attr to new-bar-code-attr.
      if varstay-history then do:
        for each old-c-bar-code-attr no-lock where
                old-c-bar-code-attr.b-code = new-bar-code-attr.b-code
            and old-c-bar-code-attr.attr-code = new-bar-code-attr.attr-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-bar-code-attr.
          buffer-copy old-c-bar-code-attr to new-c-bar-code-attr.
    end.
      end. /*if varstay-history then do:*/
    end.
  end.
  for each old-prod-bc no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc.
      buffer-copy old-prod-bc to new-prod-bc.
      if varstay-history then do:
        for each old-c-prod-bc no-lock
          where old-c-prod-bc.b-str = new-prod-bc.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc.b-code = new-prod-bc.b-code then do:
            create new-c-prod-bc.
            buffer-copy old-c-prod-bc to new-c-prod-bc.
          end.
        end.
      end. /*if varstay-history then do:*/
    end.
  end. /*  for each old-prod-bc no-lock */
  for each old-prod-bc-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-attr.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-attr.
      buffer-copy old-prod-bc-attr to new-prod-bc-attr.
      if varstay-history then do:
        for each old-c-prod-bc-attr no-lock
          where old-c-prod-bc-attr.b-str = new-prod-bc-attr.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc-attr.b-code = new-prod-bc-attr.b-code then do:
            create new-c-prod-bc-attr.
            buffer-copy old-c-prod-bc-attr to new-c-prod-bc-attr.
          end.
        end.
      end. /*if varstay-history then do:*/
    end.
  end. /*  for each old-prod-bc-attr no-lock */
  for each old-prod-bc-db no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-db.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-db.
      buffer-copy old-prod-bc-db to new-prod-bc-db.
    end.
  end. /*  for each old-prod-bc-db no-lock */
  define variable v-first-time as logical no-undo .
  define variable v-b-code as integer no-undo .
  define variable v-b-str as character no-undo .
  for each old-prod-bc-db-attr no-lock
  by old-prod-bc-db-attr.b-code
  by old-prod-bc-db-attr.b-str
  by old-prod-bc-db-attr.db-num
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if not (v-b-str = old-prod-bc-db-attr.b-str
           and
           v-b-code = old-prod-bc-db-attr.b-code) then do:
      assign
      v-first-time = yes
      v-b-str = old-prod-bc-db-attr.b-str
      v-b-code = old-prod-bc-db-attr.b-code
      .
    end.
    find first new-bar-code no-lock
      where new-bar-code.b-code = old-prod-bc-db-attr.b-code no-error.
    if available new-bar-code then do:
      create new-prod-bc-db-attr.
      buffer-copy old-prod-bc-db-attr to new-prod-bc-db-attr.
      if varstay-history
      and v-first-time
      then do:
        for each old-c-prod-bc-db-attr no-lock
          where old-c-prod-bc-db-attr.b-str = new-prod-bc-db-attr.b-str
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          if old-c-prod-bc-db-attr.b-code = new-prod-bc-db-attr.b-code then do:
            create new-c-prod-bc-db-attr.
            buffer-copy old-c-prod-bc-db-attr to new-c-prod-bc-db-attr.
          end.
        end.
      end. /*if varstay-history then do:*/
    end.
  end. /*  for each old-prod-bc-db-attr no-lock */
  for each new-goods no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    for each old-dis-gds-rule where
            old-dis-gds-rule.gds-code = new-goods.gds-code:
      create new-dis-gds-rule.
      buffer-copy old-dis-gds-rule to new-dis-gds-rule.
    end.
      if varstay-history then do:
        for each old-c-dis-gds-rule no-lock where
                old-c-dis-gds-rule.gds-code = new-dis-gds-rule.gds-code

        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-dis-gds-rule.
          buffer-copy old-c-dis-gds-rule to new-c-dis-gds-rule.
        end.
      end. /*if varstay-history then do:*/
    for each old-dis-gds-rule-attr where
            old-dis-gds-rule-attr.gds-code = new-goods.gds-code:
      create new-dis-gds-rule-attr.
      buffer-copy old-dis-gds-rule-attr to new-dis-gds-rule-attr.
    end.
  end.
  define variable v-tbl-row as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  for each old-ext-classif no-lock
    where old-ext-classif.classif-subject = {&table_goods} and not old-ext-classif.classif-name = {&extclass_goods_esys}
  break by old-ext-classif.uniq-key-rec
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if first-of(old-ext-classif.uniq-key-rec) then do:
    /*найдем товар*/
    run gen-row-keyr  in this-procedure (
                                         input  old-ext-classif.uniq-key-rec
                                        ,input  ? /* p-key-handle */
                                        ,input "dst"
                                        ,input  ? /*p-tt-handle  */
                                        ,input NO-LOCK
                                        ,output v-tbl-row
                                        ,output v-tbl-name ) no-error.
    if error-status:error then next.
    find first new-goods where rowid(new-goods)  = v-tbl-row no-lock no-error.
    if available new-goods then do:
      create new-ext-classif.
      buffer-copy old-ext-classif to new-ext-classif.
      if varstay-history then do:
        for each old-c-ext-classif no-lock where
                old-c-ext-classif.uniq-key-rec = old-ext-classif.uniq-key-rec

        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-ext-classif.
          buffer-copy old-c-ext-classif to new-c-ext-classif.
        end.
      end. /*if varstay-history then do:*/
      for each old-ext-classif-attr no-lock where
              old-ext-classif-attr.classif-subject = old-ext-classif.classif-subject
          and old-ext-classif-attr.classif-name = old-ext-classif.classif-name
          and old-ext-classif-attr.db-num = old-ext-classif.db-num
          and old-ext-classif-attr.key#_one = old-ext-classif.key#_one
          and old-ext-classif-attr.key#_two = old-ext-classif.key#_two
          and old-ext-classif-attr.key#_thre = old-ext-classif.key#_three
          and old-ext-classif-attr.charkey_one = old-ext-classif.charkey_one
          and old-ext-classif-attr.charkey_two = old-ext-classif.charkey_two
          and old-ext-classif-attr.charkey_thre = old-ext-classif.charkey_three
          and old-ext-classif-attr.nonunique = old-ext-classif.nonunique
       on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ext-classif-attr.
        buffer-copy old-ext-classif-attr to new-ext-classif-attr.
      end.
    end.
  end.
  end. /*if first-of*/
end. /*vardate-actual-goods*/
{ utl/00000002.i code-range }
{ utl/00000002.i gds-grp    }
{ utl/00000002.i gds-grp-obj    }
{ utl/00000002.i gds-grp-obj-attr    }
if varstay-history then do:
  { utl/00000002.i c-gds-grp    }
  { utl/00000002.i c-gds-grp-obj }
end.
{ utl/00000002.i dis-grp-rule   " where old-dis-grp-rule.classif-type = {&table_gds-grp} " }
{ utl/00000002.i dis-grp-rule-attr   " where old-dis-grp-rule-attr.classif-type = {&table_gds-grp} " }
if varstay-history then do:
  { utl/00000002.i c-dis-grp-rule   " where old-c-dis-grp-rule.classif-type = {&table_gds-grp} " }
end.
{ utl/00000002.i gds-grp-attr }
if varstay-history then do:
  { utl/00000002.i c-gds-grp-attr }
  { utl/00000002.i c-gds-grp-hist }
end.
{ utl/00000002.i gds-prt    }
{ utl/00000002.i gds-prt-attr    }
if varstay-history then do:
  { utl/00000002.i c-gds-prt    }
  { utl/00000002.i c-gds-prt-attr    }
end.
{ utl/00000002.i lvl-name   }
{ utl/00000002.i lvl-name-attr   }
{ utl/00000002.i ext-classif   " where old-ext-classif.classif-subject = {&table_gds-grp} " }
{ utl/00000002.i ext-classif   " where old-ext-classif.classif-name = {&extclass_goods_esys} " }
{ utl/00000002.i ext-classif-attr   " where old-ext-classif-attr.classif-subject = {&table_gds-grp} " }
{ utl/00000002.i ext-classif-attr   " where old-ext-classif-attr.classif-name = {&extclass_goods_esys} " }
if varstay-history then do:
  { utl/00000002.i c-ext-classif   " where old-c-ext-classif.classif-subject = {&table_gds-grp} " }
end.
output stream str-gen close.
return "Произведен экспорт таблиц: goods goods-attr gds-host-attr gds-obj-attr c-gds-hist c-goods c-goods-attr ~
c-gds-host-attr c-gds-obj-attr bar-code c-bar-code bar-code-attr c-bar-code-attr bar-code-attr c-bar-code-obj-attr prod-bc c-prod-bc prod-bc-attr c-prod-bc-attr prod-bc-db prod-bc-db-attr c-prod-bc-db-attr ~
dis-gds-rule   dis-gds-rule-attr   c-dis-gds-rule ~
code-range gds-grp c-gds-grp gds-grp-obj c-gds-grp-obj gds-grp-obj-attr dis-grp-rule dis-grp-rule-attr c-dis-grp-rule gds-grp-attr c-gds-grp-attr c-gds-grp-hist gds-prt c-gds-prt gds-prt-attr c-gds-prt-attr ~
lvl-name  lvl-name-attr ext-classif ext-classif-attr c-ext-classif ".
end. /*do*/