block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ коррекции отрицательных партий после прихода

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 08/16/05


*/

define input parameter pardoc-code        like ub.trn-doc.doc-code no-undo.
define input parameter parmainmenu-handle as   handle              no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Документ коррекции отрицательных партий после прихода":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/clcprtsl.i }
{ str/doc-code.i }
{ cmp/strcodec.i }
{ cmp/gds-list.i gds-list def }
{ str/get-pr.i   def }


define buffer bf-in_trn-doc        for ub.trn-doc.
define buffer bf-in_doc-line       for ub.doc-line.
define buffer bf-in_inv-line       for ub.inv-line.
define buffer bf-in_parts          for ub.parts.
define buffer bf-in_gds-dtl        for ub.gds-dtl.
define buffer bf_trn-doc           for ub.trn-doc.
define buffer bf_doc-line          for ub.doc-line.
define buffer bf_inv-line          for ub.inv-line.
define buffer bf_gds-dtl           for ub.gds-dtl.
define buffer bf-supp_parts        for ub.parts.
define buffer bf-minus_parts       for ub.parts.
define buffer bf_parts-root        for ub.parts-root.
define buffer bf_clients           for ub.clients.
define buffer bf_store             for ub.store.
define buffer bf_shop              for ub.shop.
define buffer bf_sysconf           for ub.sysconf.
define buffer bf_goods             for ub.goods.
define buffer bf_parts             for ub.parts.
define buffer bf-supp_clients      for ub.clients.
define buffer bf-control_parts     for ub.parts.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define temp-table tt-minus-doc-line no-undo like ub.doc-line
field minus-qnty as decimal
field rsrv-qnty  as decimal.
define temp-table tt-minus-parts no-undo like ub.parts
field minus-qnty as decimal
field rsrv-qnty  as decimal.
define temp-table tt-in-parts no-undo like ub.parts
field rsrv-qnty   as decimal
field unrsrv-qnty as decimal.
define temp-table tt-in-doc-line no-undo like ub.doc-line
field defect-qnty as decimal.
define variable varinv-pay                like ub.shop.inv-pay     no-undo.
define variable vardoc-code               like ub.trn-doc.doc-code no-undo.
define variable varis-petrolium           as   logical             no-undo.
define variable varis-pieces              as   logical             no-undo.
define variable varneed-rsrv-line         as   decimal             no-undo.
define variable varneed-rsrv-parts        as   decimal             no-undo.
define variable varneed-rsrv-parts-in     as   decimal             no-undo.
define variable varneed-rsrv-parts-in-mem as   decimal             no-undo.
define variable varvat-pc                 like ub.doc-line.vat-pc     no-undo.
define variable varslt-pc                 like ub.doc-line.slt-pc     no-undo.
define variable varchg-inv                as   logical             no-undo.
define variable varr-b                    as   character           no-undo.
define variable p-value                   as   character           no-undo.
define variable p-type                    as   character           no-undo.
define variable varfact-date              as   date                no-undo.
define variable varfact-time              as   integer             no-undo.
define variable varshift-date             as   date                no-undo.
define variable varshift-num              as   integer             no-undo.
define variable varshift-name             as   character           no-undo.

do on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
find first bf-in_trn-doc where bf-in_trn-doc.doc-code = pardoc-code no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
find first bf_clients where bf_clients.obj-type = bf-in_trn-doc.obj-type and
                            bf_clients.obj-code = bf-in_trn-doc.obj-code no-lock.
if bf-in_trn-doc.obj-type = {&shop} then do:
  find first bf_shop where bf_shop.obj-code = bf-in_trn-doc.obj-code no-lock.
  assign
    varinv-pay = bf_shop.inv-pay.
end.
else do:
  find first bf_store where bf_store.obj-code = bf-in_trn-doc.obj-code no-lock.
  assign
    varinv-pay = bf_store.inv-pay.
end.

for each bf-in_doc-line where bf-in_doc-line.doc-code = bf-in_trn-doc.doc-code on error undo, return error return-value :
  /*Определяем совокупность строк и партий документа для компенсации*/
  find first bf_goods where bf_goods.artic     = bf-in_doc-line.artic     and
                            bf_goods.prod-type = bf-in_doc-line.prod-type and
                            bf_goods.prod-code = bf-in_doc-line.prod-code no-lock.
  { str/is-petrl.i
    bf-in_doc-line.artic
    bf-in_doc-line.prod-type
    bf-in_doc-line.prod-code
    varis-petrolium
    varis-pieces
  }

  if varis-petrolium 
  and not varis-pieces
  then do:
    create tt-in-doc-line.
    buffer-copy bf-in_doc-line to tt-in-doc-line.
    assign
      tt-in-doc-line.defect-qnty = 0
    .
    for each bf-in_parts where bf-in_parts.out-code  = bf-in_doc-line.doc-code  and
                               bf-in_parts.obj-type  = bf-in_doc-line.obj-type  and
                               bf-in_parts.obj-code  = bf-in_doc-line.obj-code  and
                               bf-in_parts.artic     = bf-in_doc-line.artic     and
                               bf-in_parts.prod-type = bf-in_doc-line.prod-type and
                               bf-in_parts.prod-code = bf-in_doc-line.prod-code on error undo, return error return-value :
      find first bf-supp_clients where bf-supp_clients.obj-type = bf-in_parts.supp-type and
                                       bf-supp_clients.obj-code = bf-in_parts.supp-code no-lock.
      if bf-supp_clients.obj-type = {&shop}  or
         bf-supp_clients.obj-type = {&stock} then do:
        assign
          tt-in-doc-line.defect-qnty = tt-in-doc-line.defect-qnty + bf-in_parts.fact-qnty.
      end.
      else do:
        find first bf-minus_parts where bf-minus_parts.out-code  = {&free-code}    and
                                  bf-minus_parts.obj-type  = bf-in_parts.obj-type  and
                                  bf-minus_parts.obj-code  = bf-in_parts.obj-code  and
                                  bf-minus_parts.artic     = bf-in_parts.artic     and
                                  bf-minus_parts.prod-type = bf-in_parts.prod-type and
                                  bf-minus_parts.prod-code = bf-in_parts.prod-code and
                                  bf-minus_parts.part-code = bf-in_parts.part-code and
                                  bf-minus_parts.fact-qnty < 0
        no-error .
        if available bf-minus_parts
        then do :
          create tt-in-parts.
          buffer-copy bf-in_parts to tt-in-parts.
          assign
            tt-in-parts.unrsrv-qnty = tt-in-parts.fact-qnty
          .
          find first tt-minus-doc-line where tt-minus-doc-line.doc-code  = bf-in_doc-line.doc-code  and
                                             tt-minus-doc-line.artic     = bf-in_doc-line.artic     and
                                             tt-minus-doc-line.prod-type = bf-in_doc-line.prod-type and
                                             tt-minus-doc-line.prod-code = bf-in_doc-line.prod-code no-error.
          if not available tt-minus-doc-line then do:
            create tt-minus-doc-line.
            buffer-copy bf-in_doc-line to tt-minus-doc-line .
          end.
          for each bf-minus_parts where bf-minus_parts.out-code  = {&free-code}    and
                                  bf-minus_parts.obj-type  = bf-in_parts.obj-type  and
                                  bf-minus_parts.obj-code  = bf-in_parts.obj-code  and
                                  bf-minus_parts.artic     = bf-in_parts.artic     and
                                  bf-minus_parts.prod-type = bf-in_parts.prod-type and
                                  bf-minus_parts.prod-code = bf-in_parts.prod-code and
                                  bf-minus_parts.part-code = bf-in_parts.part-code and
                                  bf-minus_parts.fact-qnty < 0
          :
            find first tt-minus-parts where tt-minus-parts.out-code  = bf-minus_parts.out-code
                                        and tt-minus-parts.obj-type  = bf-minus_parts.obj-type
                                        and tt-minus-parts.obj-code  = bf-minus_parts.obj-code
                                        and tt-minus-parts.artic     = bf-minus_parts.artic
                                        and tt-minus-parts.prod-type = bf-minus_parts.prod-type
                                        and tt-minus-parts.prod-code = bf-minus_parts.prod-code
                                        and tt-minus-parts.part-code = bf-minus_parts.part-code
                                        and tt-minus-parts.prt-code  = bf-minus_parts.prt-code
            no-error .
            if not available tt-minus-parts
            then do :
              create tt-minus-parts.
              buffer-copy bf-minus_parts to tt-minus-parts.
              assign
                tt-minus-parts.minus-qnty    = - bf-minus_parts.fact-qnty
                tt-minus-doc-line.minus-qnty = tt-minus-doc-line.minus-qnty + tt-minus-parts.minus-qnty
              .
            end .
          end .
        end .
        else do :
          assign
            tt-in-doc-line.defect-qnty = tt-in-doc-line.defect-qnty + bf-in_parts.fact-qnty
          .
        end .
      end.
    end.
  end .
  else do :
    create tt-in-doc-line.
    buffer-copy bf-in_doc-line to tt-in-doc-line.
    assign
      tt-in-doc-line.defect-qnty = 0.
    for each bf-in_parts where bf-in_parts.out-code  = bf-in_doc-line.doc-code  and
                               bf-in_parts.obj-type  = bf-in_doc-line.obj-type  and
                               bf-in_parts.obj-code  = bf-in_doc-line.obj-code  and
                               bf-in_parts.artic     = bf-in_doc-line.artic     and
                               bf-in_parts.prod-type = bf-in_doc-line.prod-type and
                               bf-in_parts.prod-code = bf-in_doc-line.prod-code on error undo, return error return-value :
      find first bf-supp_clients where bf-supp_clients.obj-type = bf-in_parts.supp-type and
                                       bf-supp_clients.obj-code = bf-in_parts.supp-code no-lock.
      if bf-supp_clients.obj-type = {&shop}  or
         bf-supp_clients.obj-type = {&stock} then do:
        assign
          tt-in-doc-line.defect-qnty = tt-in-doc-line.defect-qnty + bf-in_parts.fact-qnty.
      end.
      else do:
        create tt-in-parts.
        buffer-copy bf-in_parts to tt-in-parts.
        assign
          tt-in-parts.unrsrv-qnty = tt-in-parts.fact-qnty.
      end.
    end.
    /*Формируем отрицательную зону по нашим товарам*/
    for each bf-minus_parts where bf-minus_parts.out-code  = {&free-code}             and
                                  bf-minus_parts.obj-type  = bf-in_trn-doc.obj-type   and
                                  bf-minus_parts.obj-code  = bf-in_trn-doc.obj-code   and
                                  bf-minus_parts.artic     = bf-in_doc-line.artic     and
                                  bf-minus_parts.prod-type = bf-in_doc-line.prod-type and
                                  bf-minus_parts.prod-code = bf-in_doc-line.prod-code and
  /*                                bf-minus_parts.supp-type = bf-in_trn-doc.obj-type   and*/
  /*                                bf-minus_parts.supp-code = bf-in_trn-doc.obj-code   and*/
                                  bf-minus_parts.fact-qnty < 0                        on error undo, return error return-value :
      find first tt-minus-doc-line where tt-minus-doc-line.doc-code  = bf-in_doc-line.doc-code  and
                                         tt-minus-doc-line.artic     = bf-in_doc-line.artic     and
                                         tt-minus-doc-line.prod-type = bf-in_doc-line.prod-type and
                                         tt-minus-doc-line.prod-code = bf-in_doc-line.prod-code no-error.
      if not available tt-minus-doc-line then do:
        create tt-minus-doc-line.
        buffer-copy bf-in_doc-line to tt-minus-doc-line.
      end.
      create tt-minus-parts.
      buffer-copy bf-minus_parts to tt-minus-parts.
      assign
        tt-minus-parts.minus-qnty    = - bf-minus_parts.fact-qnty
        tt-minus-doc-line.minus-qnty = tt-minus-doc-line.minus-qnty + tt-minus-parts.minus-qnty.
    end.
  end . /* не топливо */
end.
define variable vv-doc-code as character no-undo .
find first tt-minus-doc-line no-error.
if available tt-minus-doc-line then do:
  run doc-code in this-procedure (
    "main":u,
    bf-in_trn-doc.obj-type,
    bf-in_trn-doc.obj-code,
    vv-doc-code,
    output vardoc-code ) no-error.

  if error-status :error then do:
    return error return-value.
  end.
  { str/crtrndoc.i
    ?
    ?
    1
    1
    bf-in_trn-doc.host-code
    {&cmp}
    ?
    bf_clients.db-num
    bf-in_trn-doc.creid
    "' '"
    vardoc-code
    bf-in_trn-doc.doc-date
    {&inventory}
    no
    bf-in_trn-doc.host-code
    no
    bf-in_trn-doc.obj-code
    bf-in_trn-doc.obj-type
    no
    varinv-pay
    "substitute('@ Создан по внешней приходной накладной &1', bf-in_trn-doc.doc-code)"
    no
    "{&without-slt}"
    {&wayb}
    "{&inc-vat}"
    {&TDEDT_Corr_Minus_Parts}
    ?
    no-error
  }
  if error-status:error then do:
    undo, return error substitute ("Ошибка при создании документа процедурой crtrndoc &1", return-value).
  end.
  find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
  assign
    bf_trn-doc.out-code   = bf-in_trn-doc.doc-code
    bf_trn-doc.base-rate  = bf-in_trn-doc.base-rate
    bf_trn-doc.base-scale = bf-in_trn-doc.base-scale
    bf_trn-doc.boss       = bf-in_trn-doc.boss
    bf_trn-doc.agnt       = bf-in_trn-doc.agnt
    bf_trn-doc.wrkr       = bf-in_trn-doc.wrkr.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code.
  if bf_sysconf.cons-vat-pc = ?
  then do:
    return error "У Вас не установлен НДС для консигнационного товара по фирме.".
  end.

  for each tt-minus-doc-line on error undo, return error return-value :
    find first bf-in_doc-line where bf-in_doc-line.doc-code  = bf-in_trn-doc.doc-code      and
                                    bf-in_doc-line.artic     = tt-minus-doc-line.artic     and
                                    bf-in_doc-line.prod-type = tt-minus-doc-line.prod-type and
                                    bf-in_doc-line.prod-code = tt-minus-doc-line.prod-code .
    find first tt-in-doc-line where tt-in-doc-line.doc-code  = bf-in_doc-line.doc-code  and
                                    tt-in-doc-line.artic     = bf-in_doc-line.artic     and
                                    tt-in-doc-line.prod-type = bf-in_doc-line.prod-type and
                                    tt-in-doc-line.prod-code = bf-in_doc-line.prod-code .
    find first bf_goods where bf_goods.artic     = bf-in_doc-line.artic     and
                              bf_goods.prod-type = bf-in_doc-line.prod-type and
                              bf_goods.prod-code = bf-in_doc-line.prod-code no-lock.
    { str/is-petrl.i
      bf-in_doc-line.artic
      bf-in_doc-line.prod-type
      bf-in_doc-line.prod-code
      varis-petrolium
      varis-pieces
    }

    if varis-petrolium  and
       not varis-pieces then do:
      find first bf-in_inv-line where bf-in_inv-line.doc-code  = bf-in_doc-line.doc-code  and
                                      bf-in_inv-line.artic     = bf-in_doc-line.artic     and
                                      bf-in_inv-line.prod-type = bf-in_doc-line.prod-type and
                                      bf-in_inv-line.prod-code = bf-in_doc-line.prod-code .
    end.
    { gbl/pftxvalg.i
      bf_goods.gds-code
      {&vat-tax-code}
      bf-in_trn-doc.fact-date
      bf_trn-doc.host-code
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      varvat-pc
      no-error
    }
    { str/st-sltpc.i
      recid(bf_goods)
      recid(bf_trn-doc)
      bf_sysconf.cash-pay
      varslt-pc
    }
    { str/crdoclin.i
      bf_trn-doc.doc-code
      bf_goods.artic
      bf_goods.prod-type
      bf_goods.prod-code
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      bf_trn-doc.status_
      bf_trn-doc.ext-doc-type
      bf_goods.prt-root
      varvat-pc
      varslt-pc
      bf_sysconf.cons-vat-pc
    }
    find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                                 bf_doc-line.artic     = bf_goods.artic      and
                                 bf_doc-line.prod-type = bf_goods.prod-type  and
                                 bf_doc-line.prod-code = bf_goods.prod-code   .
    assign
      bf_doc-line.cli-base-rate = bf-in_doc-line.cli-base-rate
      bf_doc-line.doc-qnty      = 0
      bf_doc-line.fact-qnty     = 0.
    find first bf-in_gds-dtl where bf-in_gds-dtl.doc-code  = bf-in_trn-doc.doc-code and
                                   bf-in_gds-dtl.artic     = bf_doc-line.artic      and
                                   bf-in_gds-dtl.prod-type = bf_doc-line.prod-type  and
                                   bf-in_gds-dtl.prod-code = bf_doc-line.prod-code  .
    create bf_gds-dtl.
    assign
      bf_gds-dtl.doc-code    = bf_trn-doc.doc-code
      bf_gds-dtl.artic       = bf_doc-line.artic
      bf_gds-dtl.prod-type   = bf_doc-line.prod-type
      bf_gds-dtl.prod-code   = bf_doc-line.prod-code
      bf_gds-dtl.obj-type    = bf_trn-doc.obj-type
      bf_gds-dtl.obj-code    = bf_trn-doc.obj-code
      bf_gds-dtl.ov          = no
      bf_gds-dtl.doc-qnty    = 0
      bf_gds-dtl.fact-qnty   = 0
      bf_gds-dtl.price-base  = 0
      bf_gds-dtl.price-rubl  = 0
      bf_gds-dtl.discnt-base = 0
      bf_gds-dtl.discnt-rubl = 0
      bf_gds-dtl.prt-code    = bf-in_gds-dtl.prt-code.
    { str/get-pr.i calc bf_gds-dtl.obj-type bf_gds-dtl.obj-code bf_goods.gds-code bf_gds-dtl.prt-code }
    if gp-price-sale <> ? then do:
      ASSIGN bf_doc-line.excise   = gp-excise
             bf_doc-line.road-tax = gp-road-tax.
      if varr-b = "rubl":U then do:
        assign bf_gds-dtl.price-rubl = gp-price-sale.
      end.
      else do:
        assign bf_gds-dtl.price-base = gp-price-sale.
      end.
      if varr-b = "base":U then do:
        assign bf_gds-dtl.price-rubl = bf_gds-dtl.price-base * bf_trn-doc.base-rate / bf_trn-doc.base-scale.
      end.
      else do:
        assign bf_gds-dtl.price-base = bf_gds-dtl.price-rubl / bf_trn-doc.base-rate * bf_trn-doc.base-scale.
      end.
    end.
    cycle-parts:
    for each tt-minus-parts where tt-minus-parts.artic     = tt-minus-doc-line.artic     and
                                  tt-minus-parts.prod-type = tt-minus-doc-line.prod-type and
                                  tt-minus-parts.prod-code = tt-minus-doc-line.prod-code use-index FIFO on error undo, return error return-value :
      if bf-in_doc-line.fact-qnty - tt-in-doc-line.defect-qnty - tt-minus-doc-line.rsrv-qnty > 0 then do:
        assign
          varneed-rsrv-line = bf-in_doc-line.fact-qnty - tt-in-doc-line.defect-qnty - tt-minus-doc-line.rsrv-qnty.
        if tt-minus-parts.minus-qnty <= varneed-rsrv-line then do:
          assign
            varneed-rsrv-parts = tt-minus-parts.minus-qnty.
        end.
        else do:
          assign
            varneed-rsrv-parts = varneed-rsrv-line.
        end.
        /*сначала резервируем отрицательную партию*/
        release ub.pl-gds no-error .
        integer(tt-minus-parts.part-code) no-error .
        if not error-status:error
        then do :
          find first ub.pl-gds no-lock where ub.pl-gds.pl-code = integer(tt-minus-parts.part-code)
                                         and ub.pl-gds.gds-code = bf_goods.gds-code
                                         no-error .
        end .
        run trg/rsrv-dtl.p ( parmainmenu-handle,
                      {&rsrv-dtl_action_reserv}
                + "," + {&rsrv-dtl_rsrv-single-part}
                + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(tt-minus-parts.in-code,   "", ",=":u)
                + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(tt-minus-parts.part-code, "", ",=":u)
                + (if available ub.pl-gds then ("," + {&rsrv-dtl_pl-code} + "=" + str-encode(tt-minus-parts.part-code, "", ",=":u)) else "")
                ,
                buffer bf_gds-dtl,
                input-output varneed-rsrv-parts,
                input-output bf_doc-line.price-base,
                input-output bf_doc-line.price-rubl,
                -1, "") no-error.
        if error-status:error then do:
          undo, return error substitute ("Ошибка при резервировании свободной зоны &1", return-value ).
        end.
        if varneed-rsrv-parts <> 0 then do:
          assign
            tt-minus-parts.rsrv-qnty    = varneed-rsrv-parts
            tt-minus-doc-line.rsrv-qnty = tt-minus-doc-line.rsrv-qnty + varneed-rsrv-parts
          .
          for each tt-in-parts where tt-in-parts.out-code    = bf-in_trn-doc.doc-code and
                                     tt-in-parts.obj-type    = bf-in_trn-doc.obj-type and
                                     tt-in-parts.obj-code    = bf-in_trn-doc.obj-code and
                                     tt-in-parts.artic       = bf_doc-line.artic      and
                                     tt-in-parts.prod-type   = bf_doc-line.prod-type  and
                                     tt-in-parts.prod-code   = bf_doc-line.prod-code  and
                                     tt-in-parts.unrsrv-qnty > 0                      use-index FIFO on error undo, return error return-value :
            if varneed-rsrv-parts <= tt-in-parts.unrsrv-qnty then do:
              assign
                varneed-rsrv-parts-in = - varneed-rsrv-parts.
            end.
            else do:
              assign
                varneed-rsrv-parts-in = - tt-in-parts.unrsrv-qnty.
            end.
            assign
              varneed-rsrv-parts-in-mem   = varneed-rsrv-parts-in.
            
            release ub.pl-gds no-error .  
            integer(tt-in-parts.part-code) no-error .
            if not error-status:error
            then do :
              find first ub.pl-gds no-lock where ub.pl-gds.pl-code = integer(tt-in-parts.part-code)
                                             and ub.pl-gds.gds-code = bf_goods.gds-code
                                             no-error .
            end .
            run trg/rsrv-dtl.p ( parmainmenu-handle,
                           {&rsrv-dtl_action_reserv}
                + "," + {&rsrv-dtl_rsrv-single-part}
                + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(tt-in-parts.in-code,   "":u, ",=":u)
                + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(tt-in-parts.part-code, "":u, ",=":u)
                + (if available ub.pl-gds then ("," + {&rsrv-dtl_pl-code} + "=" + str-encode(tt-in-parts.part-code, "", ",=":u)) else "")
                , buffer bf_gds-dtl,
                input-output varneed-rsrv-parts-in,
                input-output bf_doc-line.price-base,
                input-output bf_doc-line.price-rubl,
                -1, "") no-error.
            if error-status:error then do:
              undo, return error substitute ("Ошибка при резервировании свободной зоны &1", return-value ).
            end.
            if varneed-rsrv-parts-in-mem <> varneed-rsrv-parts-in then do:
              return error substitute ("Ошибка при резервировании партий из приходного документа при корректировке отрицательных партий. Не удалось зарезервировать все количество. Товар &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
            end.
            assign
              tt-in-parts.rsrv-qnty   = tt-in-parts.rsrv-qnty   - varneed-rsrv-parts-in
              tt-in-parts.unrsrv-qnty = tt-in-parts.unrsrv-qnty + varneed-rsrv-parts-in
              varneed-rsrv-parts      = varneed-rsrv-parts      + varneed-rsrv-parts-in
            .
            create bf_parts-root.
            assign
              bf_parts-root.doc-code       = bf_trn-doc.doc-code
              bf_parts-root.orig-gds-code  = bf_goods.gds-code
              bf_parts-root.orig-in-code   = tt-minus-parts.in-code
              bf_parts-root.orig-part-code = tt-minus-parts.part-code
              bf_parts-root.gds-code       = bf_parts-root.orig-gds-code
              bf_parts-root.in-code        = tt-in-parts.in-code
              bf_parts-root.part-code      = tt-in-parts.part-code
            .
          end.
          if varneed-rsrv-parts > 0 then do:
            undo, return error substitute ("Ошибка. По свободной зоне было зарезервировано количество, которое не удалось отрезервировать по партиям приходного документа. Товар &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
          end.
        end.
      end.
      else do:
        leave cycle-parts.
      end.
    end.
    find first bf-control_parts where bf-control_parts.out-code  = bf_doc-line.doc-code  and
                                      bf-control_parts.artic     = bf_doc-line.artic     and
                                      bf-control_parts.prod-type = bf_doc-line.prod-type and
                                      bf-control_parts.prod-code = bf_doc-line.prod-code no-error.
    if not available bf-control_parts then do:
      delete bf_doc-line.
    end.
    else do:
      /*Раскидаем отрезервированные партии по признаках в количествах внешнего прихода*/
      assign
        bf_gds-dtl.doc-qnty  = 0
        bf_gds-dtl.fact-qnty = 0.
      /*Заполним топливные характеристики строки*/
      if varis-petrolium  and
         not varis-pieces then do:
        assign
          bf_doc-line.doc-density  = bf-in_doc-line.fact-density
          bf_doc-line.fact-density = bf-in_doc-line.fact-density
        .
        find first bf_inv-line exclusive-lock where bf_inv-line.doc-code        = bf_doc-line.doc-code 
                                                and bf_inv-line.artic           = bf_doc-line.artic    
                                                and bf_inv-line.prod-type       = bf_doc-line.prod-type
                                                and bf_inv-line.prod-code       = bf_doc-line.prod-code
                                                no-error .
        if not available bf_inv-line
        then do :                                       
          create bf_inv-line.
          assign
            bf_inv-line.doc-code        = bf_doc-line.doc-code
            bf_inv-line.artic           = bf_doc-line.artic
            bf_inv-line.prod-type       = bf_doc-line.prod-type
            bf_inv-line.prod-code       = bf_doc-line.prod-code
            bf_inv-line.wast-cli-qnty   = 0
            bf_inv-line.after-cli-qnty  = bf-in_inv-line.after-cli-qnty
            bf_inv-line.before-cli-qnty = bf-in_inv-line.before-cli-qnty
          .
        end .
        else do :
          assign
            bf_inv-line.after-cli-qnty  = bf_inv-line.after-cli-qnty + bf-in_inv-line.after-cli-qnty
            bf_inv-line.before-cli-qnty =  bf_inv-line.before-cli-qnty + bf-in_inv-line.before-cli-qnty
          .
        end .
      end.
      /*Заполним дополнительные суммы излишек и недостач по партиям*/
      create bf-expp_doc-line-sum.
      assign
        bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
        bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
        bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
        bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
        bf-expp_doc-line-sum.gds-code     = bf_goods.gds-code
        bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}
      .
      create bf-incp_doc-line-sum.
      assign
        bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
        bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
        bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
        bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
        bf-incp_doc-line-sum.gds-code     = bf_goods.gds-code
        bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}
      .
      for each bf_parts where bf_parts.out-code  = bf_trn-doc.doc-code and
                              bf_parts.obj-type  = bf_trn-doc.obj-type and
                              bf_parts.obj-code  = bf_trn-doc.obj-code and
                              bf_parts.artic     = bf_goods.artic      and
                              bf_parts.prod-type = bf_goods.prod-type  and
                              bf_parts.prod-code = bf_goods.prod-code  on error undo, return error return-value :
        for each tt-clcparts :
          delete tt-clcparts.
        end.
        create tt-clcparts.
        buffer-copy bf_parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure
           (input recid(tt-clcparts),
            input no,
            input no,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?,
            input ?
           ).
        find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
        if bf_parts.fact-qnty < 0 then do:
           assign
             bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
             bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
             bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
             bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
             bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
             bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
             bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
             bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
             bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
             bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
             bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
             bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
             bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
             bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
             bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
           .
        end.
        else do:
           assign
             bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
             bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
             bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
             bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
             bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
             bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
             bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
             bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
             bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
             bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
             bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
             bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
             bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
             bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
             bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
           .
        end.
      end. /*for each parts*/
    end.
  end.
  find first bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-error.
  if not available bf_doc-line then do:
    delete bf_trn-doc.
  end.
  else do:
    { str/tdat-val.i
        bf_trn-doc.doc-code
        {&trdcattr-addsum}
        p-value
        p-type
    }
    if lookup ({&sum-expense-parts}, p-value) = 0 then do:
      { str/tdat-wrt.i
          bf_trn-doc.doc-code
          {&trdcattr-addsum}
          "p-value + min(p-value,',') + {&sum-expense-parts}"
      }
    end.
    create bf-expp_trn-doc-sum.
    assign
      bf-expp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_trn-doc-sum.sum-type     = {&sum-expense-parts}.
    { str/tdat-val.i
        bf_trn-doc.doc-code
        {&trdcattr-addsum}
        p-value
        p-type
    }
    if lookup ({&sum-expense-parts}, p-value) = 0 then do:
      { str/tdat-wrt.i
          bf_trn-doc.doc-code
          {&trdcattr-addsum}
          "p-value + min(p-value,',') + {&sum-expense-parts}"
      }
    end.
    create bf-incp_trn-doc-sum.
    assign
      bf-incp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_trn-doc-sum.sum-type     = {&sum-income-parts}.
    for each bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code     and
                                        bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type and
                                        bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type     and
                                        bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code     and
                                        bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}    on error undo, return error return-value :
      assign
        bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  bf-expp_doc-line-sum.fact-qnty
        bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  bf-expp_doc-line-sum.cost-sum-base
        bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  bf-expp_doc-line-sum.cost-sum-rubl
        bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  bf-expp_doc-line-sum.cost-vat-base
        bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  bf-expp_doc-line-sum.cost-vat-rubl
        bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  bf-expp_doc-line-sum.cost-slt-base
        bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  bf-expp_doc-line-sum.cost-slt-rubl
        bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  bf-expp_doc-line-sum.cost-road-tax-base
        bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  bf-expp_doc-line-sum.cost-road-tax-rubl
        bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  bf-expp_doc-line-sum.cost-excise-base
        bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  bf-expp_doc-line-sum.cost-excise-rubl
        bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  bf-expp_doc-line-sum.cost-transport-base
        bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  bf-expp_doc-line-sum.cost-transport-rubl
        bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  bf-expp_doc-line-sum.cost-other-base
        bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  bf-expp_doc-line-sum.cost-other-rubl
      .
    end.
    for each bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code     and
                                        bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type and
                                        bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type     and
                                        bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code     and
                                        bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}     on error undo, return error return-value :
      assign
        bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  bf-incp_doc-line-sum.fact-qnty
        bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  bf-incp_doc-line-sum.cost-sum-base
        bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  bf-incp_doc-line-sum.cost-sum-rubl
        bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  bf-incp_doc-line-sum.cost-vat-base
        bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  bf-incp_doc-line-sum.cost-vat-rubl
        bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  bf-incp_doc-line-sum.cost-slt-base
        bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  bf-incp_doc-line-sum.cost-slt-rubl
        bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  bf-incp_doc-line-sum.cost-road-tax-base
        bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  bf-incp_doc-line-sum.cost-road-tax-rubl
        bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  bf-incp_doc-line-sum.cost-excise-base
        bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  bf-incp_doc-line-sum.cost-excise-rubl
        bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  bf-incp_doc-line-sum.cost-transport-base
        bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  bf-incp_doc-line-sum.cost-transport-rubl
        bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  bf-incp_doc-line-sum.cost-other-base
        bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  bf-incp_doc-line-sum.cost-other-rubl
      .
    end.
    run gbl/factdate.p (input        bf_trn-doc.obj-type,
                    input        bf_trn-doc.obj-code,
                    input-output varfact-date,
                    input-output varfact-time,
                    input-output varshift-date,
                    input-output varshift-num,
                    input-output varshift-name,
                    input        yes) no-error.
    run str/parts-pc.p (   input parmainmenu-handle
                     , input bf_trn-doc.doc-code
                     , integer({&responsible-storage-code})
                     , integer({&repayment-code})
                     , input {&fact}
                     , input varfact-date
                     , input varfact-time
                     , input varshift-date
                     , input varshift-num
                     , input varshift-name
                    ) no-error .
    if error-status:error then do:
      undo, return error substitute ("Нельзя закрыть документ автоматической коррекции отрицательных партий &1" +
                                     "не удается преобразовать товар на ответственном хранении в выкупной:&1&2 &3"
                                     ,  {&new-line}
                                     , error-status:get-message(1)
                                     , return-value
                                    ).
    end.
    run str/trn-stat.p (parmainmenu-handle,
                    this-procedure ,
                    {&close-doc},
                    bf_trn-doc.doc-code,
                    ?,
                    bf_clients.db-num,
                    ?,
                    ?,
                    ?,
                    ?,
                    yes,
                    output varchg-inv,
                    output table gds-list ).
    run gbl/calc-trn.p (input parmainmenu-handle, input recid(bf_trn-doc)).
  end.
end.
end.