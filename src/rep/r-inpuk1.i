/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

К печати короткой накладной прихода r-inp.p

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

  { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
    view-as alert-box error .
  end.

  assign mk-code = "" .
  if buf_trn-doc.obj-type = {&shop} then do:
    for each ub.cd-plu no-lock where
           ub.cd-plu.obj-type = buf_trn-doc.obj-type
       and ub.cd-plu.obj-code = buf_trn-doc.obj-code
       and ub.cd-plu.b-code = b-code:
      assign mk-code = string(ub.cd-plu.plu-code) .
    end.
  end.

  if g#gds-engl then assign gds_name = buf_goods.engl-name.
  else               assign gds_name = buf_goods.gds-name.
  assign
    Lines_Counter = Lines_Counter + 1
    tb-code = string(b-code)
  .

  { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
  { gbl/prtat.i v-root-node  "'empty-scale=request'"  empty-scale }

    run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).
    find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
    if CostPrice then do:
      if PrintRubl then do:
        assign stoim = tt-allsum-line.sum-dsc-rubl-cur  SLT-sum = tt-allsum-line.slt-rubl-cur  VAT-sum = tt-allsum-line.vat-rubl-buyer-cur .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-cur  SLT-sum = tt-allsum-line.slt-base-cur  VAT-sum = tt-allsum-line.vat-base-buyer-cur .
      end.
    end.
    else do:
      if PrintRubl then do:
        assign stoim = tt-allsum-line.sum-dsc-rubl-acc  SLT-sum = tt-allsum-line.slt-rubl-acc  VAT-sum = tt-allsum-line.vat-rubl-acc .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-acc  SLT-sum = tt-allsum-line.slt-base-acc  VAT-sum = tt-allsum-line.vat-base-acc .
      end.
    end.

    find first ub.gds-obj no-lock
      where ub.gds-obj.gds-code = buf_goods.gds-code
        and ub.gds-obj.obj-type = buf_trn-doc.obj-type
        and ub.gds-obj.obj-code = buf_trn-doc.obj-code
      no-error .
    if varr-b = "rubl":u then assign Up-fact = (ub.gds-obj.price-sale - buf_doc-line.price-rubl) / buf_doc-line.price-rubl * 100 .
                         else assign Up-fact = (ub.gds-obj.price-sale - buf_doc-line.price-base) / buf_doc-line.price-base * 100 .
    assign
      qnty    = buf_doc-line.fact-qnty
      Price   = stoim / qnty
      all-qnty    = all-qnty    + qnty
      all-stoim   = all-stoim   + stoim
      v-vat-pc = round(buf_doc-line.vat-pc,1)
      v-slt-pc = round(buf_doc-line.slt-pc,1)
    .
    find first temp-nalog where temp-nalog.vat-prc = v-vat-pc and temp-nalog.slt-prc = v-slt-pc no-error .
    if not available temp-nalog then do:
      create temp-nalog .
      assign  temp-nalog.vat-prc = v-vat-pc  temp-nalog.slt-prc = v-slt-pc  .
    end.
    assign  temp-nalog.vat-sum = temp-nalog.vat-sum + VAT-sum   temp-nalog.slt-sum = temp-nalog.slt-sum + SLT-sum   .

    if empty-scale = no and PrintScale = yes then do: /*  шкала и ее печатаем */
      display stream out_stream
        sym1  Lines_Counter sym2 tb-code sym11 mk-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6 sym7 sym8 sym9 Up-fact sym10
      with frame {1}.
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
          sym1  sym2 string(b-code) @ tb-code  sym11  sym3 sym4 ('  /'+ ub.gds-prt.f-name)  @  gds_name  sym5 sym6
          Price sym7   buf_gds-dtl.fact-qnty @ qnty  sym8 (buf_gds-dtl.fact-qnty * Price ) @ stoim sym9 sym10
        with frame {1}.
        down stream out_stream with frame {1} .
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
      display stream out_stream
        sym1 Lines_Counter sym2 tb-code sym11 mk-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6  Price sym7 qnty sym8 stoim sym9 Up-fact sym10
      with frame {1}.
      down stream out_stream with frame {1} .
    end.

/* $Workfile$ e n d */