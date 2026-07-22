/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание документа межфирменного возврата. Временные таблицы описаны в lib-def.i

Автор: Чернова Светлана Александровна
Дата создания: 12/14/03
Author: Svetlana Chernova
Creation date: 12/14/03

Автор1: Суслов Алексей Юрьевич


*/

procedure hold-ret :
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

  define buffer bf_trn-doc    for ub.trn-doc.
  define buffer bf_doc-line   for ub.doc-line.
  define buffer bf_gds-dtl    for ub.gds-dtl.
  define buffer bf_parts      for ub.parts.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts-supp for ub.parts-supp.
  define buffer bf-in_trn-doc for ub.trn-doc.
  define buffer bf-orig_parts for ub.parts.

  define variable vartotal-parts-qnty   like ub.parts.fact-qnty      no-undo.
  define variable vartotal-price-base   like ub.parts.price-base     no-undo.
  define variable vartotal-price-rubl   like ub.parts.price-rubl     no-undo.
  define variable vartotal-road-tax     like ub.parts.road-tax-base  no-undo.
  define variable cli_doc-prt           as   logical                 no-undo.
  define variable obj_doc-prt           as   logical                 no-undo.
  define variable varprt-create-n-c     like ub.gds-prt.node-code    no-undo.
  define variable vargds-dtl-chg-qnty   as   decimal                 no-undo.
  define variable vartotal-gds-dtl-qnty as   decimal                 no-undo.
  define variable varcreate-n-c         like ub.gds-prt.node-code    no-undo.
  define variable varcash-pay           like ub.sysconf.cash-pay     no-undo.
  define variable varr-b                as   character               no-undo.

do transaction on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
for each lib-trn_ret-line on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = lib-trn_ret-line.artic     and
                            bf_goods.prod-type = lib-trn_ret-line.prod-type and
                            bf_goods.prod-code = lib-trn_ret-line.prod-code no-lock.
  create bf_doc-line.
  assign
    bf_doc-line.doc-code       = bf_trn-doc.doc-code
    bf_doc-line.obj-type       = bf_trn-doc.obj-type
    bf_doc-line.obj-code       = bf_trn-doc.obj-code
    bf_doc-line.artic          = lib-trn_ret-line.artic
    bf_doc-line.prod-type      = lib-trn_ret-line.prod-type
    bf_doc-line.prod-code      = lib-trn_ret-line.prod-code
    bf_doc-line.cli-qnty       = lib-trn_ret-line.cli-qnty
    bf_doc-line.doc-qnty       = lib-trn_ret-line.doc-qnty
    bf_doc-line.fact-qnty      = lib-trn_ret-line.fact-qnty
    bf_doc-line.SLT-pc         = lib-trn_ret-line.slt-pc
    bf_doc-line.VAT-pc         = lib-trn_ret-line.vat-pc
    bf_doc-line.cons-vat-pc    = lib-trn_ret-line.cons-vat-pc
    bf_doc-line.cons-slt-pc    = lib-trn_ret-line.cons-slt-pc
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    bf_doc-line.unit-cli       = lib-trn_ret-line.unit-cli
    bf_doc-line.prt-root       = lib-trn_ret-line.prt-root
    bf_doc-line.prt-OK         = yes
    bf_doc-line.fact-order     = 0
    bf_doc-line.cli-base-rate  = lib-trn_ret-line.cli-base-rate
    bf_doc-line.doc-density    = lib-trn_ret-line.fact-density
    bf_doc-line.fact-density   = lib-trn_ret-line.fact-density
    bf_doc-line.num-place      = lib-trn_ret-line.num-place
    bf_doc-line.wt-brutto      = lib-trn_ret-line.wt-brutto.
  for each lib-trn_ret-parts
    where lib-trn_ret-parts.obj-type  = lib-trn_ret-line.obj-type
      and lib-trn_ret-parts.obj-code  = lib-trn_ret-line.obj-code
      and lib-trn_ret-parts.artic     = lib-trn_ret-line.artic
      and lib-trn_ret-parts.prod-type = lib-trn_ret-line.prod-type
      and lib-trn_ret-parts.prod-code = lib-trn_ret-line.prod-code
      and lib-trn_ret-parts.out-code  = lib-trn_ret-line.doc-code
    on error undo, return error return-value
    :
    if lib-trn_ret-parts.fact-qnty < 0 then do:
       undo, return error "В документе межфирменного перемещения. Фактическое количество в партии не может быть отрицательным." .
    end.
    find first bf_parts-supp where bf_parts-supp.in-code   = lib-trn_ret-parts.in-code   and
                                   bf_parts-supp.artic     = lib-trn_ret-parts.artic     and
                                   bf_parts-supp.prod-type = lib-trn_ret-parts.prod-type and
                                   bf_parts-supp.prod-code = lib-trn_ret-parts.prod-code and
                                   bf_parts-supp.part-code = lib-trn_ret-parts.part-code no-error.
    if not available bf_parts-supp then do:
      undo, return error substitute ("Не найдена информация о поставщике по партии &1 &2 &3 &4 &5.",
                                     lib-trn_ret-parts.in-code  ,
                                     lib-trn_ret-parts.artic    ,
                                     lib-trn_ret-parts.prod-type,
                                     lib-trn_ret-parts.prod-code,
                                     lib-trn_ret-parts.part-code ).
    end.
    find first bf-in_trn-doc where bf-in_trn-doc.doc-code = lib-trn_ret-parts.in-code no-lock no-error.
    if not available bf-in_trn-doc then do:
      undo, return error substitute ("Не найден документ с номером &1 породивший партию документа &2.", lib-trn_ret-parts.in-code, bf_trn-doc.doc-code).
    end.
    find first bf-orig_parts  where bf-orig_parts.obj-type  = bf_trn-doc.obj-type                and
                                    bf-orig_parts.obj-code  = bf_trn-doc.obj-code                and
                                    bf-orig_parts.artic     = bf_parts-supp.artic                and
                                    bf-orig_parts.prod-type = bf_parts-supp.prod-type            and
                                    bf-orig_parts.prod-code = bf_parts-supp.prod-code            and
                                    bf-orig_parts.in-code   = bf_parts-supp.orig-in-code         and
                                    bf-orig_parts.out-code  = bf-in_trn-doc.hold-doc-code-parent and
                                    bf-orig_parts.part-code = bf_parts-supp.orig-part-code       no-error.

    if not available bf-orig_parts then do:
      undo, return error substitute ("Для формирования документа необходимо наличие партии документа межфирменного расхода на наш объект. Не найдена партия: объект &1 &2 товар &3 &4 &5 документ &6 партия &7 &8.",
                                     bf_trn-doc.obj-type,
                                     bf_trn-doc.obj-code,
                                     bf_parts-supp.artic,
                                     bf_parts-supp.prod-type,
                                     bf_parts-supp.prod-code,
                                     bf-in_trn-doc.hold-doc-code-parent,
                                     bf_parts-supp.orig-in-code,
                                     bf_parts-supp.orig-part-code).
    end.
    /* В возврате может быть несколько партий по межфирменным приходным накладным на данной объекте, имеющим
       одну партию прародителя на прошлой фирме */
    find first bf_parts where bf_parts.obj-type  = bf-orig_parts.obj-type
                          and bf_parts.obj-code  = bf-orig_parts.obj-code
                          and bf_parts.artic     = bf-orig_parts.artic
                          and bf_parts.prod-type = bf-orig_parts.prod-type
                          and bf_parts.prod-code = bf-orig_parts.prod-code
                          and bf_parts.in-code   = bf-orig_parts.in-code
                          and bf_parts.out-code  = bf_trn-doc.doc-code
                          and bf_parts.part-code = bf-orig_parts.part-code no-error.
    if not available bf_parts then do:
      create bf_parts .
      assign
        bf_parts.obj-type        = bf-orig_parts.obj-type
        bf_parts.obj-code        = bf-orig_parts.obj-code
        bf_parts.artic           = bf-orig_parts.artic
        bf_parts.prod-type       = bf-orig_parts.prod-type
        bf_parts.prod-code       = bf-orig_parts.prod-code
        bf_parts.in-code         = bf-orig_parts.in-code
        bf_parts.out-code        = bf_trn-doc.doc-code
        bf_parts.part-code       = bf-orig_parts.part-code
        bf_parts.price-base      = bf-orig_parts.price-base
        bf_parts.price-rubl      = bf-orig_parts.price-rubl
        bf_parts.vat-pc          = bf-orig_parts.vat-pc
        bf_parts.pay-code        = bf-orig_parts.pay-code
        bf_parts.status_         = no
        bf_parts.supp-type       = bf-orig_parts.supp-type
        bf_parts.supp-code       = bf-orig_parts.supp-code
        bf_parts.rsrv-free       = ?
        bf_parts.doc-type        = bf_trn-doc.doc-type
        bf_parts.pl-code         = bf-orig_parts.pl-code
        bf_parts.vat-type        = bf-orig_parts.vat-type
        bf_parts.exch-code       = bf-orig_parts.exch-code
        bf_parts.price-cli       = bf-orig_parts.price-cli
        bf_parts.cli-base-rate   = bf-orig_parts.cli-base-rate
        bf_parts.slt-pc          = bf-orig_parts.slt-pc
        bf_parts.host-code       = bf-orig_parts.host-code
        bf_parts.is-supp         = bf-orig_parts.is-supp
        bf_parts.slt-type        = bf-orig_parts.slt-type
        bf_parts.cst-code        = bf-orig_parts.cst-code
        bf_parts.last-date       = bf-orig_parts.last-date
        bf_parts.road-tax-base   = bf-orig_parts.road-tax-base
        bf_parts.road-tax-rubl   = bf-orig_parts.road-tax-rubl
        bf_parts.transport-base  = bf-orig_parts.transport-base
        bf_parts.transport-rubl  = bf-orig_parts.transport-rubl
        bf_parts.other-base      = bf-orig_parts.other-base
        bf_parts.other-rubl      = bf-orig_parts.other-rubl
        bf_parts.purch-code      = bf-orig_parts.purch-code
        bf_parts.cli-qnty        = lib-trn_ret-parts.cli-qnty
        bf_parts.real-qnty       = bf-orig_parts.real-qnty
        bf_parts.qnty            = lib-trn_ret-parts.qnty
        bf_parts.fact-qnty       = lib-trn_ret-parts.fact-qnty
        .
    end.
    else do:
      assign
        bf_parts.cli-qnty        = bf_parts.cli-qnty  + lib-trn_ret-parts.cli-qnty
        bf_parts.real-qnty       = bf_parts.real-qnty + bf-orig_parts.real-qnty
        bf_parts.qnty            = bf_parts.qnty      + lib-trn_ret-parts.qnty
        bf_parts.fact-qnty       = bf_parts.fact-qnty + lib-trn_ret-parts.fact-qnty
        .
    end.
  end. /* for each lib-trn_ret-parts ...  */

  assign
    vartotal-parts-qnty = 0
    vartotal-price-base = 0
    vartotal-price-rubl = 0
    vartotal-road-tax   = 0
  .

  for each bf_parts
    where bf_parts.obj-type  = bf_doc-line.obj-type
      and bf_parts.obj-code  = bf_doc-line.obj-code
      and bf_parts.artic     = bf_doc-line.artic
      and bf_parts.prod-type = bf_doc-line.prod-type
      and bf_parts.prod-code = bf_doc-line.prod-code
      and bf_parts.out-code  = bf_doc-line.doc-code
  on error undo, return error return-value
  :
    assign
      vartotal-parts-qnty = vartotal-parts-qnty + bf_parts.fact-qnty
      vartotal-price-base = vartotal-price-base + bf_parts.fact-qnty * bf_parts.price-base
      vartotal-price-rubl = vartotal-price-rubl + bf_parts.fact-qnty * bf_parts.price-rubl
    .
    if varr-b = "rubl":u then do:
      assign
        vartotal-road-tax   = vartotal-road-tax   + bf_parts.fact-qnty * bf_parts.road-tax-rubl
      .
    end.
    else do:
      assign
        vartotal-road-tax   = vartotal-road-tax   + bf_parts.fact-qnty * bf_parts.road-tax-rubl
      .
    end.
  end. /* each parts */

  if bf_doc-line.fact-qnty <> vartotal-parts-qnty then do:
    undo, return error substitute ("Количество в партиях не совпадает с количеством в строке документа. Количество по документу = &1 Количество по партиям = &2 ", bf_doc-line.fact-qnty, vartotal-parts-qnty).
  end.

  if vartotal-parts-qnty <> 0 then do:
    assign
      bf_doc-line.price-rubl = vartotal-price-rubl / vartotal-parts-qnty
      bf_doc-line.price-base = vartotal-price-base / vartotal-parts-qnty
      bf_doc-line.price-cli  = vartotal-price-base / vartotal-parts-qnty
      bf_doc-line.road-tax   = vartotal-road-tax   / vartotal-parts-qnty
    .
  end.
  { gbl/objat.i
    bf_trn-doc.hold-obj-type
    bf_trn-doc.hold-obj-code
    "'doc-prt=request':u"
    cli_doc-prt
    no-error
  }
  if error-status:error then do:
    undo, return error return-value.
  end.
  { gbl/objat.i
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    "'doc-prt=request':u"
    obj_doc-prt
    no-error
  }
  if error-status:error then do:
    undo, return error return-value.
  end.
  if cli_doc-prt <> obj_doc-prt then do:
    /* атрибуты "признаки включены/выключены" отличаются для объектов
       необходимо преобразование gds-dtl
     */
    /* если на объекте, куда мы перемещаем товар - выключены признаки
          то gds-dtl необходимо привязать к корню
       если на объекте, куда мы перемещаем товар - включены признаки
          то gds-dtl необходимо привязать к первому терминальному признаку
     */
    /* ищем корневой признак для товара */
    { gbl/rootnode.i
      bf_goods.artic
      bf_goods.prod-type
      bf_goods.prod-code
      varprt-create-n-c
      no-error
    }
    if error-status:error then do:
      return error return-value.
    end.

    if cli_doc-prt = true then do:
      /* признаки включены - ищем первый терминальный признак */
      { gbl/termnode.i
        varprt-create-n-c
        varprt-create-n-c
        no-error
      }
      if error-status:error then do:
        return error return-value.
      end.
    end.
  end. /* отличаются признаки */
  assign
    vartotal-gds-dtl-qnty = 0
  .

  for each lib-trn_ret-dtl no-lock
    where lib-trn_ret-dtl.doc-code  = lib-trn_ret-line.doc-code
      and lib-trn_ret-dtl.prod-type = lib-trn_ret-line.prod-type
      and lib-trn_ret-dtl.prod-code = lib-trn_ret-line.prod-code
      and lib-trn_ret-dtl.artic     = lib-trn_ret-line.artic
  on error undo, return error
  :
    if lib-trn_ret-dtl.fact-qnty < 0 then do:
      undo, return error "В документе межфирменного перемещения в строке признака не может быть задано отрицательное количество".
    end.
    if lib-trn_ret-dtl.fact-qnty = 0 then do:
      next.
    end.

    if cli_doc-prt = obj_doc-prt then do:
      assign
        varcreate-n-c = lib-trn_ret-dtl.prt-code
      .
    end.
    else do:
      assign
        varcreate-n-c = varprt-create-n-c
      .
    end.
    create bf_gds-dtl.
    assign
      bf_gds-dtl.doc-code    = bf_trn-doc.doc-code
      bf_gds-dtl.artic       = lib-trn_ret-dtl.artic
      bf_gds-dtl.prod-type   = lib-trn_ret-dtl.prod-type
      bf_gds-dtl.prod-code   = lib-trn_ret-dtl.prod-code
      bf_gds-dtl.prt-code    = varcreate-n-c
      bf_gds-dtl.obj-type    = bf_trn-doc.obj-type
      bf_gds-dtl.obj-code    = bf_trn-doc.obj-code
      bf_gds-dtl.discnt-base = lib-trn_ret-dtl.discnt-base
      bf_gds-dtl.discnt-rubl = lib-trn_ret-dtl.discnt-rubl
      bf_gds-dtl.discnt-pc   = lib-trn_ret-dtl.discnt-pc
      bf_gds-dtl.discnt-type = lib-trn_ret-dtl.discnt-type
      bf_gds-dtl.price-base  = lib-trn_ret-dtl.price-base
      bf_gds-dtl.price-rubl  = lib-trn_ret-dtl.price-rubl
      bf_gds-dtl.fact-qnty   = lib-trn_ret-dtl.fact-qnty
      bf_gds-dtl.doc-qnty    = lib-trn_ret-dtl.doc-qnty
      bf_gds-dtl.ov          = yes
      vartotal-gds-dtl-qnty  = vartotal-gds-dtl-qnty + bf_gds-dtl.fact-qnty
    .
  end. /* each ret-dtl */
  if vartotal-gds-dtl-qnty <> bf_doc-line.fact-qnty then do:
    undo, return error substitute ("Количество в признаках не совпадает с количеством в строке документа. Количество по строкам документа = &1 Количество по признакам = &2", bf_doc-line.fact-qnty, vartotal-gds-dtl-qnty).
  end.
end. /* each lib-trn_ret-line */
find first bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-error.
if not available bf_doc-line then do:
  /* не было создано ни одной линии */
  /* удаляем документ */
  delete bf_trn-doc.
end.
end. /* transaction */
end procedure. /* hold-ret */

