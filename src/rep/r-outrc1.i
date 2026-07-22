/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

К печати короткой накладной расхода, возврата и списания r-outrec.p для таможни

Автор: Демин Алексей Сергеевич
Дата создания: 03/13/08
Author: Alexey Demin
Creation date: 03/13/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


    { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.

    { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
    { gbl/prtat.i v-root-node  "'empty-scale=request'"  empty-scale }

    run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).
    find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
    if CostPrice then do:
      if PrintRubl then do:
        assign stoim = tt-allsum-line.sum-dsc-rubl-acc  SLT-sum = tt-allsum-line.slt-rubl-acc  VAT-sum = tt-allsum-line.vat-rubl-acc .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-acc  SLT-sum = tt-allsum-line.slt-base-acc  VAT-sum = tt-allsum-line.vat-base-acc .
      end.
    end.
    else do:
      if PrintRubl then do:
        assign stoim = tt-allsum-line.sum-dsc-rubl-doc  SLT-sum = tt-allsum-line.slt-rubl-doc  VAT-sum = tt-allsum-line.vat-rubl-buyer-doc .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-doc  SLT-sum = tt-allsum-line.slt-base-doc  VAT-sum = tt-allsum-line.vat-base-buyer-doc .
      end.
    end.
    assign
      varwt-brutto  = 0
      varnum-place = 0
      v-gtd = ""
    .
    for each ub.parts where ub.parts.out-code  = buf_doc-line.doc-code  and
                         ub.parts.obj-type  = buf_doc-line.obj-type  and
                         ub.parts.obj-code  = buf_doc-line.obj-code  and
                         ub.parts.artic     = buf_doc-line.artic     and
                         ub.parts.prod-type = buf_doc-line.prod-type and
                         ub.parts.prod-code = buf_doc-line.prod-code no-lock,
         first ub.parts-attr where ub.parts-attr.in-code   = parts.in-code      and
                                ub.parts-attr.gds-code  = buf_goods.gds-code and
                                ub.parts-attr.part-code = parts.part-code :
      if parts-attr.cst-code <> "" then assign v-gtd = parts-attr.cst-code .
      assign
        varwt-brutto = varwt-brutto + (if parts-attr.wt-brutto = ? then 0 else parts-attr.wt-brutto / parts-attr.fact-qnty * parts.fact-qnty)
        varnum-place = varnum-place + (if parts-attr.num-place = ? then 0 else parts-attr.num-place / parts-attr.fact-qnty * parts.fact-qnty)
      .
    end.
    if g#gds-engl then assign gds_name = buf_goods.engl-name.
    else               assign gds_name = buf_goods.gds-name.
    assign
      Lines_Counter = Lines_Counter + 1
      tb-code = string(b-code)
      qnty    = buf_doc-line.fact-qnty
      Price   = stoim / qnty
      all-qnty    = all-qnty    + qnty
      all-stoim   = all-stoim   + stoim
      all-SLT-sum = all-SLT-sum + SLT-sum
      all-VAT-sum = all-VAT-sum + VAT-sum
      varall-wt-brutto = varall-wt-brutto + varwt-brutto
      varall-num-place = varall-num-place + varnum-place
      v-vat-pc = round(buf_doc-line.vat-pc,1)
      v-slt-pc = round(buf_doc-line.slt-pc,1)
    .
    find first temp-nalog where temp-nalog.vat-prc = v-vat-pc and temp-nalog.slt-prc = v-slt-pc no-error .
    if not available temp-nalog then do:
      create temp-nalog .
      assign
        temp-nalog.vat-prc = v-vat-pc
        temp-nalog.slt-prc = v-slt-pc
      .
    end.
    assign
      temp-nalog.vat-sum = temp-nalog.vat-sum + VAT-sum
      temp-nalog.slt-sum = temp-nalog.slt-sum + SLT-sum
      temp-nalog.from-sum = temp-nalog.from-sum + stoim
    .

    if empty-scale = no and PrintScale = yes then do: /*  шкала и ее печатаем */
      display stream out_stream
        sym1  Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6 sym7 sym8 sym10 sym11 sym12 v-gtd sym13
      with frame {1}.
      if p-doc = "r-outret" then
        run outretxl-write-line-data in this-procedure (
                  input Lines_Counter
                , input tb-code
                , input buf_goods.artic
                , input gds_name
                , input buf_goods.unit-base
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input v-gtd
        ).

      &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  /*sym9  SLT-sum*/  with frame {1}. &endif
      down stream out_stream with frame {1} .

      /* смотрим признаки */
      for each buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
        :
        { gbl/gdsbcode.i  buf_goods.gds-code  buf_gds-dtl.prt-code  b-code  no-error }
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" buf_goods.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
          view-as alert-box error .
        end.
        find first ub.gds-prt where ub.gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

        if not CostPrice then do:
          if PrintRubl then assign Price = buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl .
          else              assign Price = buf_gds-dtl.price-base - buf_gds-dtl.discnt-base .
        end.
        display stream out_stream
          sym1  sym2 string(b-code) @ tb-code sym3 sym4 ('  /'+ gds-prt.f-name)  @  gds_name  sym5 sym6
          Price sym7   buf_gds-dtl.fact-qnty @ qnty  sym8 (buf_gds-dtl.fact-qnty * Price ) @ stoim  sym10
          varwt-brutto
          sym11
          varnum-place
          sym12  sym13
        with frame {1}.
        if p-doc = "r-outret" then
          run outretxl-write-line-data in this-procedure (
                  input ""
                , input string(b-code)
                , input ""
                , input ('  /'+ gds-prt.f-name)
                , input ""
                , input string( Price )
                , input string( buf_gds-dtl.fact-qnty )
                , input string( (buf_gds-dtl.fact-qnty * Price ) )
                , varwt-brutto
                , varnum-place
                , ""
          ).
        &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  /*sym9*/  with frame {1}. &endif
        down stream out_stream with frame {1} .
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
      display stream out_stream
        sym1 Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6  Price sym7 qnty sym8 stoim sym10 varwt-brutto sym11 varnum-place sym12 v-gtd sym13
      with frame {1}.
      if p-doc = "r-outret" then
        run outretxl-write-line-data in this-procedure (
                  input Lines_Counter
                , input tb-code
                , input buf_goods.artic
                , input gds_name
                , input buf_goods.unit-base
                , input string( Price )
                , input string( qnty )
                , input string( stoim )
                , input varwt-brutto
                , input varnum-place
                , input v-gtd
        ).
      &if "{1}" = "rubl" or "{1}" = "val" &then   display stream out_stream  /*sym9  SLT-sum*/  with frame {1}.   &endif
      down stream out_stream with frame {1} .

    end.

/* $Workfile$ e n d */