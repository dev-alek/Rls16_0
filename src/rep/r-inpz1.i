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

/*  if g#gds-engl then assign gds_name = buf_goods.engl-name.*/
/*  else               assign gds_name = buf_goods.gds-name.*/
  assign
    gds_name = buf_goods.gds-name
    Lines_Counter = Lines_Counter + 1
    tb-code = string(b-code)
  .

  { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
  { gbl/prtat.i v-root-node  "'empty-scale=request'"  empty-scale }

  &if "{1}" = "akt" &then
    assign
      Price       = buf_doc-line.fact-qnty
      qnty        = buf_doc-line.doc-qnty
      all-qnty    = all-qnty    + qnty
      all-stoim   = all-stoim   + Price
    .
    if empty-scale = no and PrintScale = yes then do: /*  шкала и ее печатаем */
      display stream out_stream sym1  Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6 sym7 sym8 sym9 with frame {1}.
      down stream out_stream with frame {1} .
      if buf_goods.engl-name <> "" then  do:
        display stream out_stream sym1 sym2 buf_goods.engl-name  @ gds_name  sym5 sym6 sym8 sym7 sym9  with frame {1} .
        down stream out_stream 1 with frame {1} .
      end.

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
        find first gds-prt where gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

        display stream out_stream
          sym1  sym2   string(b-code)           @ tb-code
          sym3 sym4    ('  /'+ gds-prt.f-name)  @ gds_name
          sym5 sym6    buf_gds-dtl.fact-qnty    @ Price
          sym7         buf_gds-dtl.doc-qnty     @ qnty
          sym8 (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty ) @ stoim
          sym9
        with frame {1}.
        down stream out_stream with frame {1} .
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
      display stream out_stream sym1 Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6  Price sym7 qnty sym8 (Price - qnty) @ stoim sym9  with frame {1}.
      down stream out_stream with frame {1} .
      if buf_goods.engl-name <> "" then  do:
        display stream out_stream sym1 sym2 buf_goods.engl-name  @ gds_name  sym5 sym6 sym8 sym7 sym9  with frame {1} .
        down stream out_stream 1 with frame {1} .
      end.
    end.

  &else

    run r-cost in this-procedure ( input buf_doc-line.doc-code  ,input buf_doc-line.artic ,input buf_doc-line.prod-type
            ,input buf_doc-line.prod-code  ,output t-dec       ,output v-vat-pc   ,output v-slt-pc
            ,output v-sum-base             ,output v-sum-rubl  ,output v-vat-base ,output v-vat-rubl
            ,output v-slt-base             ,output v-slt-rubl  ,output t-dec      ,output t-dec
            ,output t-dec   ,output t-dec  ,output t-dec       ,output t-dec      ,output t-dec   ,output t-dec ) no-error .
    if PrintRubl then  assign   stoim   = v-sum-rubl    SLT-sum = v-slt-rubl    VAT-sum = v-vat-rubl  .
    else               assign   stoim   = v-sum-base    SLT-sum = v-slt-base    VAT-sum = v-vat-base  .

    if stoim < 0 then  assign   stoim   = - stoim       SLT-sum = - SLT-sum     VAT-sum = - VAT-sum   .

    find first gds-obj no-lock
      where gds-obj.gds-code = buf_goods.gds-code
        and gds-obj.obj-type = buf_trn-doc.obj-type
        and gds-obj.obj-code = buf_trn-doc.obj-code
      no-error .
    if available gds-obj then do:
      if varr-b = "rubl":u then assign Up-fact = (gds-obj.price-sale - buf_doc-line.price-rubl) / buf_doc-line.price-rubl * 100 .
                           else assign Up-fact = (gds-obj.price-sale - buf_doc-line.price-base) / buf_doc-line.price-base * 100 .
    end.
    else              assign Up-fact = ? .
    assign
      qnty    = buf_doc-line.fact-qnty
      Price   = stoim / qnty
      all-qnty    = all-qnty    + qnty
      all-stoim   = all-stoim   + stoim
      v-vat-pc = round(v-vat-pc,1)
      v-slt-pc = round(v-slt-pc,1)
    .
    find first temp-nalog where temp-nalog.vat-prc = v-vat-pc and temp-nalog.slt-prc = v-slt-pc no-error .
    if not available temp-nalog then do:
      create temp-nalog .
      assign  temp-nalog.vat-prc = v-vat-pc  temp-nalog.slt-prc = v-slt-pc  .
    end.
    assign  temp-nalog.vat-sum = temp-nalog.vat-sum + VAT-sum   temp-nalog.slt-sum = temp-nalog.slt-sum + SLT-sum   .

    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .

    if empty-scale = no and PrintScale = yes and num-form <> 4 then do: /*  шкала и ее печатаем */
      display stream out_stream
        sym1  Lines_Counter sym2 sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6 sym7 sym8 sym9
        &if "{1}" = "zum-rubl" &then
          buf_clients.obj-name
        &endif
        &if "{1}" = "rubl" &then
          tb-code  Up-fact sym10
        &endif
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
        find first gds-prt where gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

        if not CostPrice then do:
          if PrintRubl then assign Price = buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl .
          else              assign Price = buf_gds-dtl.price-base - buf_gds-dtl.discnt-base .
        end.
        display stream out_stream
          sym1  sym2  sym3 sym4 ('  /'+ gds-prt.f-name)  @  gds_name  sym5 sym6
          Price sym7   buf_gds-dtl.fact-qnty @ qnty  sym8 (buf_gds-dtl.fact-qnty * Price ) @ stoim sym9
          &if "{1}" = "rubl" &then
            string(b-code) @ tb-code sym10
          &endif
        with frame {1}.
        down stream out_stream with frame {1} .
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
      display stream out_stream
        sym1 Lines_Counter sym2 sym3 buf_goods.artic sym4 gds_name sym5 buf_goods.unit-base sym6  Price sym7 qnty sym8 stoim sym9
        &if "{1}" = "zum-rubl" &then
          buf_clients.obj-name
        &endif
        &if "{1}" = "rubl" &then
          tb-code  Up-fact sym10
        &endif
      with frame {1}.
      down stream out_stream with frame {1} .
      if buf_goods.engl-name <> "" then  do:
        display stream out_stream sym1 sym2 sym3 sym4 buf_goods.engl-name  @ gds_name  sym5 sym6 sym8 sym7 sym9  with frame {1} .
        down stream out_stream 1 with frame {1} .
      end.
      if num-form = 4 then do:
        goods_PS = ENTRY( 1, buf_goods.PS , chr( 10 ) ) .
        DO i = 2 TO ( NUM-ENTRIES( buf_goods.PS , chr( 10 ) ) ) :
          goods_PS = goods_PS + " " + ENTRY( i, buf_goods.PS , chr( 10 ) ) .
        END.
        goods_PS = trim( goods_PS ) .

        DO WHILE TRUE :
          if length( goods_PS ) <= {&Size-Form} then do:
            PUT STREAM Out_Stream ":" format "X(1)" goods_PS format "X({&Size-Form})"  ":"  format "X(1)" SKIP .
            LEAVE .
          end .
          else do:
            goods_PS1 = breakstr(goods_PS, {&Size-Form}, input-output  goods_PS1, input-output  goods_PS2).
            PUT STREAM Out_Stream ":" format "X(1)" goods_PS1 format "X({&Size-Form})"  ":"  format "X(1)" SKIP .
            goods_PS = trim( goods_PS2 ) .
          end.
        END .
      end.
    end.
  &endif

/* $Workfile$ e n d */