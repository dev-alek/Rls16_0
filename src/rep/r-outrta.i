/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

К печати короткой накладной расхода, возврата и списания r-outrta.p

Автор: Чернова Светлана Александровна
Дата создания: 12/22/09
Author: Svetlana Chernova
Creation date: 12/22/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".


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
        assign stoim = tt-allsum-line.sum-dsc-rubl-acc   .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-acc   .
      end.
    end.
    else do:
      if PrintRubl then do:
        assign stoim = tt-allsum-line.sum-dsc-rubl-doc  .
      end.
      else do:
        assign stoim = tt-allsum-line.sum-dsc-base-doc  .
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

    .

    if empty-scale = no and PrintScale = yes then do: /*  шкала и ее печатаем */
      display stream out_stream
        sym1  Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5  sym6 sym7 sym8 sym10
      with frame {1}.
      &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream   with frame {1}. &endif
      down stream out_stream with frame {1} .

        run outretxl-write-line-data in this-procedure (
                  input Lines_Counter
                , input tb-code
                , input buf_goods.artic
                , input gds_name
                , input ""
                , input ""
                , input ""
                , input ""
        ).

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
          sym1  sym2 string(b-code) @ tb-code sym3 sym4 ('  /'+ gds-prt.f-name)  @  gds_name  sym5 sym6
          Price sym7   buf_gds-dtl.fact-qnty @ qnty  sym8 (buf_gds-dtl.fact-qnty * Price ) @ stoim  sym10
        with frame {1}.
        &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  /*sym9*/  with frame {1}. &endif
        down stream out_stream with frame {1} .

          run outretxl-write-line-data in this-procedure (
                  input ""
                , input string(b-code)
                , input ""
                , input ('  /'+ gds-prt.f-name)
                , input ""
                , input string( Price )
                , input string( buf_gds-dtl.fact-qnty )
                , input string( (buf_gds-dtl.fact-qnty * Price ) )
          ).
      end.
    end.
    else do:   /* нет шкалы или ее не печатаем */
    find first ub.gds-obj no-lock where
               ub.gds-obj.gds-code = buf_goods.gds-code and
               ub.gds-obj.obj-type = buf_doc-line.obj-type and
               ub.gds-obj.obj-code = buf_doc-line.obj-code and
               ub.gds-obj.cash-parts = true no-error .

    if buf_doc-line.is-parts = true  or available ub.gds-obj
      then do:  /* среднепродажная хрень */
      display stream out_stream
        sym1  Lines_Counter sym2 tb-code sym3 buf_goods.artic sym4 gds_name sym5  sym6 sym7 sym8 sym10
      with frame {1}.
      &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream   with frame {1}. &endif
      down stream out_stream with frame {1} .

        run outretxl-write-line-data in this-procedure (
                  input Lines_Counter
                , input tb-code
                , input buf_goods.artic
                , input gds_name
                , input ""
                , input ""
                , input ""
                , input ""
        ).
      stoim = 0.
        for each ub.parts no-lock
          where ub.parts.out-code  = buf_doc-line.doc-code
            and ub.parts.artic     = buf_doc-line.artic
            and ub.parts.prod-type = buf_doc-line.prod-type
            and ub.parts.prod-code = buf_doc-line.prod-code
          :
          find first ub.bar-code no-lock where
                    ub.bar-code.gds-code  = buf_goods.gds-code and
                    ub.bar-code.in-code   = ub.parts.in-code and
                    ub.bar-code.part-code = ub.parts.part-code
                    no-error .
           find first buf1_clients no-lock  where
                      buf1_clients.obj-code = ub.parts.supp-code and
                      buf1_clients.obj-type = ub.parts.supp-type no-error .

          if not CostPrice then do:
/*            { gbl/bcodeprc.i*/
/*              ub.parts.obj-type*/
/*              ub.parts.obj-code*/
/*              ub.bar-code.b-code*/
/*              0*/
/*              gp-fact-order*/
/*              gp-doc-num*/
/*              Price*/
/*              gp-road-tax*/
/*              gp-excise*/
/*              no-error }*/

            run lineattr-value-parts
              (  input t-doc.doc-code
               , input buf_goods.gds-code
               , input ub.parts.part-code
               , input ub.parts.in-code
               , input {&lineattr-parts_price-sale}
               , output Price
              ) no-error .

          end.
          else do:
              if PrintRubl then do:
                Price =  ub.parts.price-rubl.
              end.
              else do:
                Price =  ub.parts.price-base.
              end.
          end.
          stoim = stoim + ub.parts.fact-qnty * Price .

          display stream out_stream
            sym1
            sym2 string(ub.bar-code.b-code) @ tb-code
            sym3
            sym4  ub.parts.part-code  @  buf_goods.unit-base
            sym5  " " + buf1_clients.obj-name @ gds_name
            sym6  Price
            sym7  ub.parts.fact-qnty @ qnty
            sym8 (ub.parts.fact-qnty * Price ) @ stoim
            sym10
          with frame {1}.
          &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  /*sym9*/  with frame {1}. &endif
          down stream out_stream with frame {1} .
            run outretxl-write-line-data in this-procedure (
                    input ""
                  , input string(ub.bar-code.b-code)
                  , input ""
                  , input "__" + buf1_clients.obj-name
                  , input ub.parts.part-code
                  , input string( Price )
                  , input string( ub.parts.fact-qnty )
                  , input string( (ub.parts.fact-qnty * Price ) )
            ).
        end. /* for each parts */
      end.
      else do:
            display stream out_stream
              sym1 Lines_Counter
              sym2 tb-code
              sym3 buf_goods.artic
              sym4 gds_name
              sym5
              sym6 Price
              sym7 qnty
              sym8 stoim
              sym10
            with frame {1}.
            &if "{1}" = "rubl" or "{1}" = "val" &then   display stream out_stream  with frame {1}.   &endif
            down stream out_stream with frame {1} .

            &if "{1}" = "rubl" or "{1}" = "val" &then display stream out_stream  with frame {1}. &endif

              run outretxl-write-line-data in this-procedure (
                        input Lines_Counter
                      , input tb-code
                      , input buf_goods.artic
                      , input gds_name
                      , input ""
                      , input string( Price )
                      , input string( qnty )
                      , input string( stoim )
              ).
      end.
    end.
    all-stoim   = all-stoim   + stoim.
/* $Workfile$ e n d */