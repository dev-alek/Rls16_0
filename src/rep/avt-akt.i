
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Шаланин Сергей Владимирович
Дата создания: 13/2/15
Author: Shalanin Sergey 
Creation date: 13/2/15

Required:

*/


FOR EACH t-doc-line :
          delete t-doc-line.
       END.


       CREATE t-doc-line.
       BUFFER-COPY doc-line TO t-doc-line.
       { gbl/hostcode.i doc-line.obj-type doc-line.obj-code v-host-code }
        if prod-price = yes
        then do:
            { gbl/pftxvalg.i
                goods.gds-code
                {&vat-tax-code}
                ?
                v-host-code
                doc-line.obj-type
                doc-line.obj-code
                v-vat-pc
                no-error
            }
            { gbl/pftxvalg.i
                    goods.gds-code
                    {&slt-tax-code}
                    ?
                    v-host-code
                    doc-line.obj-type
                    doc-line.obj-code
                    v-slt-pc
                    no-error
            }
        end.
        else do:
            { gbl/pftxvalg.i
                goods.gds-code
                {&vat-tax-code}
                t-doc.fact-date
                v-host-code
                doc-line.obj-type
                doc-line.obj-code
                v-vat-pc
                no-error
            }
            { gbl/pftxvalg.i
                    goods.gds-code
                    {&slt-tax-code}
                    t-doc.fact-date
                    v-host-code
                    doc-line.obj-type
                    doc-line.obj-code
                    v-slt-pc
                    no-error
            }
        end.
        assign
            t-doc-line.vat-pc = v-vat-pc
            t-doc-line.slt-pc = v-slt-pc
        .
       FIND bar-code WHERE bar-code.gds-code = goods.gds-code
                       AND bar-code.unit-cli = goods.unit-base
                       AND bar-code.node-code = gds-dtl.prt-code
                       AND bar-code.part-code = ""
                       AND bar-code.in-code = ""
                           NO-LOCK no-error.

        if prod-price = yes
        then do:
                { str/get-pr.i calc t-doc.obj-type t-doc.obj-code goods.gds-code bar-code.node-code }
                assign price-lst = gp-price-sale.
            end.
        else do:
            assign price-lst = gds-dtl.cur-base.
        end.

        if t-doc.doc-type = {&income}
        then do:
            { str/in-vatp.i calc doc-line. t-doc. g }
            if road-tax-rubl-loc = ? then assign road-tax-rubl-loc = 0.
            if road-tax-base-loc = ? then assign road-tax-base-loc = 0.
            assign
                price-doc = ( if v-curr-r-b = {&r-b-base}
                              then ( price-base-with-tax-loc - vat-base-loc )
                              else ( price-rubl-with-tax-loc - vat-rubl-loc ) )
                v-tax-sum = ( if v-curr-r-b = {&r-b-base}
                              then road-tax-base-loc
                              else road-tax-rubl-loc )
            .
        end.
        else do:
            if v-curr-r-b = {&r-b-base}
            then do:
                assign
                    price-doc = gds-dtl.price-base - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
            else do:
                assign
                    price-doc = gds-dtl.price-rubl - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
        end.
        assign
            Vat-gds = ( price-lst - {&SLT-calc-ov} - v-tax-sum) * t-doc-line.vat-pc / ( 100 + t-doc-line.vat-pc )
            marg = price-lst - price-doc - Vat-gds - {&SLT-calc-ov}
        .

        ACCUMULATE
            bar-code.b-code ( COUNT )
            gds-dtl.fact-qnty ( TOTAL )
            marg * gds-dtl.fact-qnty ( TOTAL )
            gds-dtl.fact-qnty * {&SLT-calc-ov} ( TOTAL )
            gds-dtl.fact-qnty * VAT-gds ( TOTAL )
            ( gds-dtl.fact-qnty * price-lst ) ( TOTAL )
            ( gds-dtl.fact-qnty * price-doc ) ( TOTAL )
        .
        if v-curr-r-b = {&r-b-base}
        then do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        else do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        assign
             delt = ( if v-curr-r-b = {&r-b-base}
                      then string( ( price-lst - gds-dtl.price-base ) / gds-dtl.price-base * 100, "->>>9.9" )
                      else string( ( price-lst - gds-dtl.price-rubl ) / gds-dtl.price-rubl * 100, "->>>9.9" )
                    ) + "%"
        .
        DISPLAY sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                price-doc
                ( gds-dtl.fact-qnty * price-doc ) @ sum-no-NDS
                ( gds-dtl.fact-qnty * ( if v-curr-r-b = {&r-b-base} then gds-dtl.price-base else gds-dtl.price-rubl ) ) @ doc-sum
                price-lst
                ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
               /* ( gds-dtl.fact-qnty * {&SLT-calc-ov} ) @ SLT-sum */
                t-doc-line.vat-pc
                ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                string( string( marg / price-doc * 100, "->>>9.9" ) + "%" ) @ UpFact
                Delt
                sym2
        .
        IF LENGTH(goods.gds-name, "CHARACTER") > 33 and FullGdsName  THEN  do:
          assign propis = SUBSTRING(goods.gds-name,34) .
          DOWN 1 .
          DISPLAY sym1 propis @ goods.gds-name  sym2     .
        end.

        /* собираем суммы по % НДС */
        find first tt-tax exclusive-lock
          where tt-tax.vat-pc = t-doc-line.vat-pc
        no-error .
        if not available tt-tax
        then do:
          create tt-tax no-error .
          assign
            tt-tax.vat-pc = t-doc-line.vat-pc
          .
        end.
        assign
          tt-tax.sum-no-nds = tt-tax.sum-no-nds + ( gds-dtl.fact-qnty * price-doc )
          tt-tax.doc-sum    = tt-tax.doc-sum    + ( gds-dtl.fact-qnty * ( if v-curr-r-b = {&r-b-base} then gds-dtl.price-base else gds-dtl.price-rubl ) )
          tt-tax.obj-sum    = tt-tax.obj-sum    + ( gds-dtl.fact-qnty * price-lst )
          /*tt-tax.slt-sum    = tt-tax.slt-sum    + ( gds-dtl.fact-qnty * {&SLT-calc-ov} )*/
          tt-tax.vat-sum    = tt-tax.vat-sum    + ( gds-dtl.fact-qnty * VAT-gds )
          tt-tax.fact-qnty  = tt-tax.fact-qnty  + gds-dtl.fact-qnty
        no-error .
       
       
       
       
       