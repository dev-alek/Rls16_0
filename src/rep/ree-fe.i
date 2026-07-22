/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусое из отчета Реестр докуиентов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  ii = ii + 1.
  { rep/repfrm.i disp ii }
/*-----------------------------------------------------------------------------------------------------------------------*/
  Find ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
  if avail ub.trn-doc then do:
                    Assign
                      fact-date      = ub.trn-doc.fact-date
                      doc-code       = ub.ot-tot.doc-code
                      cli-name       = ub.trn-doc.cli-name
                      /* qnty           = ub.ot-tot.fact-qnty */
                      .

                    end.
 else do:
 Assign
      fact-date      = ?
      doc-code       = ub.ot-tot.doc-code
      cli-name       = ""
      qnty           = 0
      .
      end.
/* продажная цена */

      IF ub.ot-tot.sum-type = {&arh-crsa{2}} /*корневая запись */ THEN DO:

              If  ub.ot-tot.ext-doc-type = {&TDEDT_Overturn} then DO:
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.

                  Assign
                    fact-date      = If ub.ot-tot.ext-doc-type <> {&TDEDT_Overturn} then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE date(''))
                    doc-code       = ub.ot-tot.doc-code
                    cli-name       = If ub.ot-tot.ext-doc-type <> {&TDEDT_Overturn} then ub.trn-doc.cli-name Else ""
                    qnty           = ub.ot-tot.fact-qnty
                    Sale-sum-ot   = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.

                    Accumulate Sale-sum-ot (TOTAL) .
              End.

            if  ub.ot-tot.ext-doc-type = {&TDEDT_Inv} then do :
               /* разбираемся с инвентаризацией */
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                              Assign
                                  fact-date      = ub.trn-doc.fact-date
                                  doc-code       = ub.ot-tot.doc-code
                                  cli-name       = ub.trn-doc.cli-name
                                  qnty           = ub.ot-tot.fact-qnty
                                  .
                if not can-find
                (first cost-ot-tot-inv where
                       cost-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       cost-ot-tot-inv.sum-type = {&arh-cost{2}} no-lock )
                        Then
                        Assign
                          SumWithNDS-coast    = 0
                          VAT-Sum-coast       = 0
                          SLT-sum-coast       = 0
                          SumWithoutNDS-coast = 0
                        .

                if not can-find
                (first sale-ot-tot-inv where
                       sale-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       sale-ot-tot-inv.sum-type = {&arh-sale{2}} no-lock )
                        Then
                        Assign
                          discnt-sum   =      0
                          ov-sum       =      0
                          VAT-Sum      =      0
                          SLT-sum      =      0
                          SumWithoutNDS =     0
                          SumWithNDS    =     0
                          .
            End.

      End.
/*-------------------------------------------------------------------------------------------------*/
/* цены документа */
      IF ub.ot-tot.sum-type = {&arh-sale{2}} /*корневая запись */ THEN DO:
          Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              If  ub.ot-tot.ext-doc-type = {&TDEDT_Overturn} then
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
                   /* run calc-discnt-base. */
          Assign
          fact-date      = If ub.ot-tot.ext-doc-type <> {&TDEDT_Overturn} then  ub.trn-doc.fact-date Else (If Available ub.price-doc then ub.price-doc.fact-date ELSE date(''))
          doc-code       = ub.ot-tot.doc-code
          cli-name       = If ub.ot-tot.ext-doc-type <> {&TDEDT_Overturn} then ub.trn-doc.cli-name Else " "
          qnty           = ub.ot-tot.fact-qnty
          /* сумма по документу */
          SumWithNDS     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
          iF SumWithNDS = ? tHEN SumWithNDS = 0.

          If not Available ub.trn-doc Then
             Assign    discnt-sum     = 0
                       ov-sum         = 0.

          discnt-sum     = if tPrintRubl then ub.ot-tot.other-rubl
                                         else ub.ot-tot.other-base .

           iF discnt-sum = ? tHEN discnt-sum = 0.
           if ub.ot-tot.ext-doc-type = {&TDEDT_Inv} THEN discnt-sum = 0.
          /* продажная цена ?????*/
          Assign
          VAT_pc         = 0
          VAT-Sum        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT_pc         = 0
          SLT-sum        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base.
          iF VAT-Sum = ? tHEN VAT-Sum = 0.
          iF SLT-sum = ? tHEN slt-Sum = 0.
          SumWithoutNDS  = SumWithNDS - VAT-Sum.   /* без НДС */
            FIND LAST crsa-ot-tot where
                crsa-ot-tot.doc-code = ub.ot-tot.doc-code   and
                crsa-ot-tot.sum-type = {&arh-crsa{2}}    and
                crsa-ot-tot.cat-id   = ub.ot-tot.cat-id  no-lock use-index pi.
                if available crsa-ot-tot then
                sale-sum       = if tPrintRubl then crsa-ot-tot.sum-rubl else crsa-ot-tot.sum-base .
                Else sale-sum  = 0.

                ov-sum =  sale-sum - ( SumWithNDS +  discnt-sum ).

          Accumulate sale-sum     (TOTAL) .
          Accumulate qnty         (TOTAL) .
          Accumulate SumWithNDS   (TOTAL) .
          Accumulate discnt-sum   (TOTAL) .
          Accumulate ov-sum       (TOTAL) .
          Accumulate VAT-Sum      (TOTAL) .
          Accumulate SLT-sum      (TOTAL) .
          Accumulate SumWithoutNDS  (TOTAL) .
       End. /* if then */
/*-------------------------------------------------------------------------*/
/* учетные цены */
      IF ub.ot-tot.sum-type = {&arh-cost{2}} /*корневая запись */ THEN DO:
          /* учетная цена */
          Assign
          SumWithNDS-coast     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base
          VAT-Sum-coast        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT-sum-coast        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base
          SumWithoutNDS-coast  = SumWithNDS-coast - VAT-Sum-coast.
          if fact-date = date('') and ub.ot-tot.ext-doc-type <> {&TDEDT_Overturn} then do:
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                                    Assign
                                        fact-date      = ub.trn-doc.fact-date
                                        doc-code       = ub.ot-tot.doc-code
                                        cli-name       = ub.trn-doc.cli-name
                                        /* qnty           = ub.ot-tot.fact-qnty */
                                        .
          end.
          Accumulate SumWithNDS-coast          (TOTAL) .
          Accumulate VAT-Sum-coast             (TOTAL) .
          Accumulate SLT-sum-coast             (TOTAL) .
          Accumulate SumWithoutNDS-coast       (TOTAL) .
       End. /* if then */
/*-------------------------------------------------------------------------------------------------*/
/* сбор расшифровок НДС и НП по учетным и ценам документа */
     IF ub.ot-tot.sum-type BEGINS {&arh-cost{2}} and ub.ot-tot.sum-type <> {&arh-cost{2}} Then DO:
            IF CostSum Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = {&single-cat-id} Then DO: { rep/tmptax.i VAT 1 i}  End.
                 Else DO: { rep/tmptax.i slt 2 j } End.
              End.
          End.
     IF ub.ot-tot.sum-type BEGINS {&arh-sale{2}} and ub.ot-tot.sum-type <> {&arh-sale{2}} Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = {&single-cat-id} Then DO: { rep/tmptax.i VAT 1 i }  End.
                 Else DO: { rep/tmptax.i slt 2 j } End.

     End.

      IF ub.ot-tot.sum-type BEGINS {&arh-crsa{2}} and ub.ot-tot.sum-type <> {&arh-crsa{2}} Then DO:
                IF entry (2 , ub.ot-tot.cat-id) = {&single-cat-id} Then DO: { rep/tmptax.i VAT 1 i }  End.
                  Else DO: { rep/tmptax.i slt 2 j } End.

      End.

          if first-of ( {1} ) then  run break-h-1.

          if last-of ( ub.ot-tot.doc-code ) then do:
              if (ub.ot-tot.sum-type     =  {&arh-crsa{2}}  and
                 not (ub.ot-tot.ext-doc-type = {&tdedt_inv} ))
                 then do:
                    run break-ot.
                    if ub.ot-tot.ext-doc-type = {&tdedt_corr_acc_price} and costsum then run break-cost.
                 end.
                 else do:
                    run break-1str.
                    if available ub.trn-doc then do:
                      if (absolute(ub.trn-doc.fact-qnty) - absolute(ub.trn-doc.doc-qnty) <> 0)
                          and ub.ot-tot.ext-doc-type <> {&tdedt_inv}
                          then run break-akt.
                      end.
                    if costsum then run break-cost.
                    run break-2str.
                    if dispupfact then run break-disp .
                 end.
             run erase-var.
          end.

          if last-of ( {1} ) then do:
              qnty               = accum total       qnty                       .
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
              { rep/acc-eq.i vat i}
              { rep/acc-eq.i slt j}
         &if "{2}" <> "" &then
          assign
                quantity3  = quantity3   + qnty
                coast5     = coast5      + sumwithnds-coast
                coast6     = coast6      + sale-sum
                .
         &endif

             run break-f-1.

             End.
/*-------------------------------------------------------------------------------------------------*/
/* $Workfile$ e n d */