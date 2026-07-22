/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок из отчета Реестр докуиентов по типу пр

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 01/09/02 12:51

*/
      ii = ii + 1.
      { rep/repfrm.i disp ii }
/*-----------------------------------------------------------------------------------------------------------------------*/
/* продажная цена */
              If  ub.aht-ot-tot.ext-doc-type = {&TDEDT_Overturn} then DO:
/*  переоценки */
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.aht-ot-tot.doc-code no-lock no-error.
                  Assign
                    fact-date      = If ub.aht-ot-tot.ext-doc-type <> {&TDEDT_Overturn} then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE date(''))
                    doc-code       = ub.aht-ot-tot.doc-code
                    cli-name       = If ub.aht-ot-tot.ext-doc-type <> {&TDEDT_Overturn} then ub.trn-doc.cli-name Else ""
                    qnty           = ub.aht-ot-tot.fact-qnty
                    Sale-sum-ot   = if tPrintRubl then ub.aht-ot-tot.crsa-sum-rubl else ub.aht-ot-tot.crsa-sum-base.
                    Accumulate Sale-sum-ot (TOTAL) .
              End.

            if  ub.aht-ot-tot.ext-doc-type = {&TDEDT_Inv} then do :
 /* разбираемся с инвентаризацией */
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.aht-ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                        Assign
                            fact-date      = ub.trn-doc.fact-date
                            doc-code       = ub.aht-ot-tot.doc-code
                            cli-name       = ub.trn-doc.cli-name
                            qnty           = ub.aht-ot-tot.fact-qnty
                            .

            Assign
              SumWithNDS-coast    = ub.aht-ot-tot.cost-sum-rubl
              VAT-Sum-coast       = ub.aht-ot-tot.cost-vat-rubl
              SLT-sum-coast       = ub.aht-ot-tot.cost-slt-rubl
              SumWithoutNDS-coast = SumWithNDS-coast - VAT-Sum-coast

              discnt-sum    =   0
              ov-sum        =   0
              VAT-Sum       = if tPrintRubl then  ub.aht-ot-tot.sale-vat-rubl else ub.aht-ot-tot.sale-vat-base
              SLT-sum       = if tPrintRubl then  ub.aht-ot-tot.sale-slt-rubl else ub.aht-ot-tot.sale-slt-base
              SumWithNDS    = if tPrintRubl then  ub.aht-ot-tot.sale-sum-rubl else ub.aht-ot-tot.sale-sum-base
              SumWithoutNDS =  SumWithNDS - VAT-Sum
              sale-sum      = if tPrintRubl then ub.aht-ot-tot.crsa-sum-rubl else ub.aht-ot-tot.crsa-sum-base .
              .

            End.

/*-------------------------------------------------------------------------------------------------*/
/* цены документа */
  If  ub.aht-ot-tot.ext-doc-type <> {&TDEDT_Overturn}  and
      ub.aht-ot-tot.ext-doc-type <> {&TDEDT_Inv}
      then DO:
          /* сумма по документу */
          Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.aht-ot-tot.doc-code no-lock no-error.
          Assign
            fact-date      = ub.trn-doc.fact-date
            doc-code       = ub.aht-ot-tot.doc-code
            cli-name       = ub.trn-doc.cli-name
            qnty           = ub.aht-ot-tot.fact-qnty
            SumWithNDS     = If Tprintrubl Then ub.aht-ot-tot.Sale-sum-rubl Else ub.aht-ot-tot.Sale-sum-base
            Discnt-sum     = If Tprintrubl Then ub.aht-ot-tot.Sale-discnt-rubl Else ub.aht-ot-tot.Sale-discnt-base
          .
          iF SumWithNDS = ? tHEN SumWithNDS = 0.
          iF discnt-sum = ? tHEN discnt-sum = 0.
          /* продажная цена ?????*/
          Assign
          VAT_pc         = 0
          VAT-Sum        = if tPrintRubl then ub.aht-ot-tot.sale-VAT-rubl else ub.aht-ot-tot.sale-VAT-base
          SLT_pc         = 0
          SLT-sum        = if tPrintRubl then ub.aht-ot-tot.sale-SLT-rubl else ub.aht-ot-tot.sale-SLT-base
          .
          iF VAT-Sum = ? tHEN VAT-Sum = 0.
          iF SLT-sum = ? tHEN slt-Sum = 0.
          SumWithoutNDS  = SumWithNDS - VAT-Sum.   /* без НДС */

          sale-sum   = if tPrintRubl then ub.aht-ot-tot.crsa-sum-rubl else ub.aht-ot-tot.crsa-sum-base .
          ov-sum =  sale-sum - ( SumWithNDS +  discnt-sum ).

          Accumulate sale-sum     (TOTAL) .
          Accumulate qnty         (TOTAL) .
          Accumulate SumWithNDS   (TOTAL) .
          Accumulate discnt-sum   (TOTAL) .
          Accumulate ov-sum       (TOTAL) .
          Accumulate VAT-Sum      (TOTAL) .
          Accumulate SLT-sum      (TOTAL) .
          Accumulate SumWithoutNDS  (TOTAL) .
/* учетные цены */
          Assign
          SumWithNDS-coast     = if tPrintRubl then ub.aht-ot-tot.cost-sum-rubl else ub.aht-ot-tot.cost-sum-base
          VAT-Sum-coast        = if tPrintRubl then ub.aht-ot-tot.cost-vat-rubl else ub.aht-ot-tot.cost-vat-base
          SLT-sum-coast        = if tPrintRubl then ub.aht-ot-tot.cost-slt-rubl else ub.aht-ot-tot.cost-slt-base
          SumWithoutNDS-coast  = SumWithNDS-coast - VAT-Sum-coast.
          Accumulate SumWithNDS-coast          (TOTAL) .
          Accumulate VAT-Sum-coast             (TOTAL) .
          Accumulate SLT-sum-coast             (TOTAL) .
          Accumulate SumWithoutNDS-coast       (TOTAL) .
       End. /* if then */

/*-------------------------------------------------------------------------------------------------*/
          If FIRST-OF ( {1} ) then  run break-h-1.

          If LAST-OF ( ub.aht-ot-tot.doc-code ) then DO:
              IF ub.aht-ot-tot.ext-doc-type  =  {&TDEDT_Overturn}   then DO:  run break-ot. end.
                 Else DO:
                    run break-1str.
                    if available ub.trn-doc then
                      if (absolute(ub.trn-doc.fact-qnty) - absolute(ub.trn-doc.doc-qnty) <> 0) and
                          (aht-ot-tot.ext-doc-type <> {&tdedt_inv} and
                           ub.aht-ot-tot.ext-doc-type <> {&tdedt_corr_acc_price} )
                          then run break-akt.
                    if costsum then run break-cost.
                    run break-2str.
                    if dispupfact then run break-disp .
                 end.
              run erase-var.
          end.

          if last-of ( {1} ) then do:
              qnty               = accum total       qnty.
              sumwithnds         = accum total       sumwithnds                 .
              discnt-sum         = accum total       discnt-sum                 .
              ov-sum             = accum total       ov-sum                     .
              vat-sum            = accum total       vat-sum                    .
              slt-sum            = accum total       slt-sum                    .
              sumwithoutnds      = accum total       sumwithoutnds              .
              sumwithnds-coast   = accum total       sumwithnds-coast           .
              vat-sum-coast      = accum total       vat-sum-coast              .
              slt-sum-coast      = accum total       slt-sum-coast              .
              sumwithoutnds-coast= accum total       sumwithoutnds-coast        .
              sale-sum-ot        = accum total       sale-sum-ot                .
              sale-sum           = (accum total       sale-sum   )  + sale-sum-ot  .
             run break-f-1.
          end.
/*-------------------------------------------------------------------------------------------------*/
/* $Workfile$ e n d */