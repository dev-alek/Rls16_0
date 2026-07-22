/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 10/24/05
Author: Svetlana Chernova
Creation date: 10/24/05

*/

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.

    { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
    { gbl/prtat.i v-root-node  "'empty-scale=request'"  empty-scale }

    run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).
    find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
    if not available tt-allsum-line then do:
         message
        "Не рассчитаны строки в процедуре  clcprtsl_calc-line  для строки документа "
        buf_doc-line.line-num skip
        "Артикул : "buf_doc-line.artic  skip
        view-as alert-box error .
        return error return-value .
    end.
    if CostPrice then do:
      if PrintRubl then do:
        assign
           stoim = tt-allsum-line.sum-dsc-rubl-acc + tt-allsum-line.dsc-rubl-acc
           stoim-d = tt-allsum-line.sum-dsc-rubl-acc
           SLT-sum = tt-allsum-line.slt-rubl-acc
           VAT-sum = tt-allsum-line.vat-rubl-acc
           .
      end.
      else do:
        assign
          stoim = tt-allsum-line.sum-dsc-base-acc  + tt-allsum-line.dsc-base-acc
          stoim-d = tt-allsum-line.sum-dsc-base-acc
          SLT-sum = tt-allsum-line.slt-base-acc
          VAT-sum = tt-allsum-line.vat-base-acc
          .
      end.
    end.
    else do:
      if PrintRubl then do:
        assign
          stoim = tt-allsum-line.sum-dsc-rubl-doc + tt-allsum-line.dsc-rubl-doc
          stoim-d = tt-allsum-line.sum-dsc-rubl-doc
          SLT-sum = tt-allsum-line.slt-rubl-doc
          VAT-sum = tt-allsum-line.vat-rubl-buyer-doc .
      end.
      else do:
        assign
           stoim = tt-allsum-line.sum-dsc-base-doc + tt-allsum-line.dsc-base-doc
           stoim-d = tt-allsum-line.sum-dsc-base-doc
           SLT-sum = tt-allsum-line.slt-base-doc
           VAT-sum = tt-allsum-line.vat-base-buyer-doc .
      end.
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
      temp-nalog.sum     = temp-nalog.sum     + stoim-d
      temp-nalog.slt-sum = temp-nalog.slt-sum + SLT-sum
    .

    if empty-scale = no and PrintScale = yes then do: /*  шкала и ее печатаем */
      display stream out_stream
        sym1  Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6 sym7 sym8 sym10
      with frame {1}.
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
          if PrintRubl then assign Price = buf_gds-dtl.price-rubl /* - buf_gds-dtl.discnt-rubl */.
          else              assign Price = buf_gds-dtl.price-base /* - buf_gds-dtl.discnt-base */.
        end.
        display stream out_stream
          sym1  sym2 string(b-code) @ tb-code sym3 sym4 ('  /'+ ub.gds-prt.f-name)  @  gds_name  sym5 sym6
          Price sym7   buf_gds-dtl.fact-qnty @ qnty  sym8 (buf_gds-dtl.fact-qnty * Price ) @ stoim  sym10
        with frame {1}.
        &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  /*sym9*/  with frame {1}. &endif
        down stream out_stream with frame {1} .
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
      display stream out_stream
        sym1 Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6  Price sym7 qnty sym8 stoim sym10
      with frame {1}.
      &if "{1}" = "rubl" or "{1}" = "val" &then   display stream out_stream  /*sym9  SLT-sum*/  with frame {1}.   &endif
      down stream out_stream with frame {1} .

    end.

/* $Workfile$ e n d */