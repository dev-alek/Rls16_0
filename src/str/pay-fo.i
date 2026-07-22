/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедуры, используемые в нескольких файлах с для оплаты ФО

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StrTax Dialog-Frame
PROCEDURE StrTax :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define input-output parameter str as character no-undo .
    assign str = " В т.ч.: "  .

    for each tt0-fin-doc-tax :
      if tt0-fin-doc-tax.with-vat = no then next.
      if str <> " В т.ч.: " then str = str + "," .
      if tt-fin-doc.curr-code = 0 then
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
    end.
    if str = " В т.ч.: " then assign str = "" .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE InvertCli Dialog-Frame
PROCEDURE InvertCli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
      define variable payer-bank-name    like ub.fin-doc.payer-bank-name  .
      define variable payer-bank-city    like ub.fin-doc.payer-bank-city  .
      define variable payer-bik          like ub.fin-doc.payer-bik        .
      define variable payer-c-schet      like ub.fin-doc.payer-c-schet    .
      define variable payer-code         like ub.fin-doc.payer-code       .
      define variable payer-code-schet   like ub.fin-doc.payer-code-schet .
      define variable payer-inn          like ub.fin-doc.payer-inn        .
      define variable payer-kpp          like ub.fin-doc.payer-kpp        .
      define variable payer-name         like ub.fin-doc.payer-name       .
      define variable payer-okpo         like ub.fin-doc.payer-okpo       .
      define variable payer-passport     like ub.fin-doc.payer-passport   .
      define variable payer-r-schet      like ub.fin-doc.payer-r-schet    .
      define variable payer-type         like ub.fin-doc.payer-type       .
      assign
        tt-fin-doc.sum-rubl  = - tt-fin-doc.sum-rubl
        tt-fin-doc.sum-base  = - tt-fin-doc.sum-base
        tt-fin-doc.sum-doc   = - tt-fin-doc.sum-doc
        tt-fin-doc.sum-contr = - tt-fin-doc.sum-contr
        payer-bank-name      = tt-fin-doc.payer-bank-name
        payer-bank-city      = tt-fin-doc.payer-bank-city
        payer-bik            = tt-fin-doc.payer-bik
        payer-c-schet        = tt-fin-doc.payer-c-schet
        payer-code           = tt-fin-doc.payer-code
        payer-code-schet     = tt-fin-doc.payer-code-schet
        payer-inn            = tt-fin-doc.payer-inn
        payer-kpp            = tt-fin-doc.payer-kpp
        payer-name           = tt-fin-doc.payer-name
        payer-okpo           = tt-fin-doc.payer-okpo
        payer-passport       = tt-fin-doc.payer-passport
        payer-r-schet        = tt-fin-doc.payer-r-schet
        payer-type           = tt-fin-doc.payer-type
        tt-fin-doc.payer-bank-name    = tt-fin-doc.receiver-bank-name
        tt-fin-doc.payer-bank-city    = tt-fin-doc.receiver-bank-city
        tt-fin-doc.payer-bik          = tt-fin-doc.receiver-bik
        tt-fin-doc.payer-c-schet      = tt-fin-doc.receiver-c-schet
        tt-fin-doc.payer-code         = tt-fin-doc.receiver-code
        tt-fin-doc.payer-code-schet   = tt-fin-doc.receiver-code-schet
        tt-fin-doc.payer-inn          = tt-fin-doc.receiver-inn
        tt-fin-doc.payer-kpp          = tt-fin-doc.receiver-kpp
        tt-fin-doc.payer-name         = tt-fin-doc.receiver-name
        tt-fin-doc.payer-okpo         = tt-fin-doc.receiver-okpo
        tt-fin-doc.payer-passport     = tt-fin-doc.receiver-passport
        tt-fin-doc.payer-r-schet      = tt-fin-doc.receiver-r-schet
        tt-fin-doc.payer-type         = tt-fin-doc.receiver-type
        tt-fin-doc.receiver-bank-name =  payer-bank-name
        tt-fin-doc.receiver-bank-city =  payer-bank-city
        tt-fin-doc.receiver-bik       =  payer-bik
        tt-fin-doc.receiver-c-schet   =  payer-c-schet
        tt-fin-doc.receiver-code      =  payer-code
        tt-fin-doc.receiver-code-schet = payer-code-schet
        tt-fin-doc.receiver-inn       =  payer-inn
        tt-fin-doc.receiver-kpp       =  payer-kpp
        tt-fin-doc.receiver-name      =  payer-name
        tt-fin-doc.receiver-okpo      =  payer-okpo
        tt-fin-doc.receiver-passport  =  payer-passport
        tt-fin-doc.receiver-r-schet   =  payer-r-schet
        tt-fin-doc.receiver-type      =  payer-type
      .
      for each  tt0-fin-doc-tax no-lock :
        assign
          tt0-fin-doc-tax.sum-line-doc       = - tt0-fin-doc-tax.sum-line-doc
          tt0-fin-doc-tax.sum-vat-line-doc   = - tt0-fin-doc-tax.sum-vat-line-doc
          tt0-fin-doc-tax.sum-slt-line-doc   = - tt0-fin-doc-tax.sum-slt-line-doc
          tt0-fin-doc-tax.sum-line-rubl      = - tt0-fin-doc-tax.sum-line-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl  = - tt0-fin-doc-tax.sum-vat-line-rubl
          tt0-fin-doc-tax.sum-slt-line-rubl  = - tt0-fin-doc-tax.sum-slt-line-rubl
          tt0-fin-doc-tax.sum-line-base      = - tt0-fin-doc-tax.sum-line-base
          tt0-fin-doc-tax.sum-vat-line-base  = - tt0-fin-doc-tax.sum-vat-line-base
          tt0-fin-doc-tax.sum-slt-line-base  = - tt0-fin-doc-tax.sum-slt-line-base
          tt0-fin-doc-tax.sum-line-contr     = - tt0-fin-doc-tax.sum-line-contr
          tt0-fin-doc-tax.sum-vat-line-contr = - tt0-fin-doc-tax.sum-vat-line-contr
          tt0-fin-doc-tax.sum-slt-line-contr = - tt0-fin-doc-tax.sum-slt-line-contr
        .
      end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CheckCli Dialog-Frame
PROCEDURE CheckCli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    /* анализируем получателя и плательщика */
    if tt-fin-doc.payer-code = p-host-code and tt-fin-doc.payer-type = {&cmp} then do: /* платим мы */
      assign
        tt-fin-doc.payer-bik        = buf_contract.own-bik
        tt-fin-doc.payer-code-schet = buf_contract.own-code-schet
        tt-fin-doc.payer-inn        = buf_contract.own-inn
        tt-fin-doc.payer-kpp        = buf_contract.own-kpp
      .
      /* анализируем получателя */
      if tt-fin-doc.receiver-code = buf_contract.cli-code and tt-fin-doc.receiver-type = buf_contract.cli-type then do:
        assign
          tt-fin-doc.receiver-bik        = buf_contract.cli-bik
          tt-fin-doc.receiver-code-schet = buf_contract.cli-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.cli-inn
          tt-fin-doc.receiver-kpp        = buf_contract.cli-kpp
        .
      end.
      else do:
        if tt-fin-doc.receiver-code = buf_contract.posr-code and tt-fin-doc.receiver-type = buf_contract.posr-type then do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.posr-bik
            tt-fin-doc.receiver-code-schet = buf_contract.posr-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.posr-inn
            tt-fin-doc.receiver-kpp        = buf_contract.posr-kpp
          .
        end.
        else do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.agnt-bik
            tt-fin-doc.receiver-code-schet = buf_contract.agnt-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.agnt-inn
            tt-fin-doc.receiver-kpp        = buf_contract.agnt-kpp
          .
        end.
      end.
    end.
    else do:
      if tt-fin-doc.receiver-code = p-host-code and tt-fin-doc.receiver-type = {&cmp} then do: /* платят нам */
        assign
          tt-fin-doc.receiver-bik        = buf_contract.own-bik
          tt-fin-doc.receiver-code-schet = buf_contract.own-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.own-inn
          tt-fin-doc.receiver-kpp        = buf_contract.own-kpp
        .
        /* анализируем получателя */
        if tt-fin-doc.payer-code = buf_contract.cli-code and tt-fin-doc.payer-type = buf_contract.cli-type then do:
          assign
            tt-fin-doc.payer-bik        = buf_contract.cli-bik
            tt-fin-doc.payer-code-schet = buf_contract.cli-code-schet
            tt-fin-doc.payer-inn        = buf_contract.cli-inn
            tt-fin-doc.payer-kpp        = buf_contract.cli-kpp
          .
        end.
        else do:
          if tt-fin-doc.payer-code = buf_contract.posr-code and tt-fin-doc.payer-type = buf_contract.posr-type then do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.posr-bik
              tt-fin-doc.payer-code-schet = buf_contract.posr-code-schet
              tt-fin-doc.payer-inn        = buf_contract.posr-inn
              tt-fin-doc.payer-kpp        = buf_contract.posr-kpp
            .
          end.
          else do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.agnt-bik
              tt-fin-doc.payer-code-schet = buf_contract.agnt-code-schet
              tt-fin-doc.payer-inn        = buf_contract.agnt-inn
              tt-fin-doc.payer-kpp        = buf_contract.agnt-kpp
            .
          end.
        end.
      end.
      else return error .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UchetCode Dialog-Frame
PROCEDURE UchetCode :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    case tt-fin-doc.fin-doc-type :
      when {&income-cash} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-cash
        .
      end.
      when {&expense-cash} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-cash
        .
      end.
      when {&income-cashless} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in
/*        tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in*/
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in
        .
      end.
      when {&expense-cashless} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out
/*        tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out*/
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out
        .
      end.
      when {&income-payoff} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-payoff
        .
      end.
      when {&expense-payoff} then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-payoff
        .
      end.
    end.
    find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.host-code = p-host-code and ub.fin-code-cel-nazn.fin-code = tt-fin-doc.cel-nazn-code no-error .
    if available ub.fin-code-cel-nazn then assign tt-fin-doc.cel-nazn-value = ub.fin-code-cel-nazn.code-value .
    find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.host-code = p-host-code and ub.fin-code-an-uchet.fin-code = tt-fin-doc.an-uchet-code no-error .
    if available ub.fin-code-an-uchet then assign tt-fin-doc.an-uchet-value = ub.fin-code-an-uchet.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc1 no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindBank Dialog-Frame
PROCEDURE FindBank :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
  find first b1_fin-schet no-lock where b1_fin-schet.host-code = p-host-code and b1_fin-schet.code-schet = tt-fin-doc.receiver-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b1_fin-schet.code-bank no-error .
  if available b1_fin-schet then
  assign
    tt-fin-doc.receiver-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.receiver-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.receiver-c-schet    = b1_fin-schet.c-schet
    tt-fin-doc.receiver-r-schet    = b1_fin-schet.r-schet
  .
  find first b2_fin-schet no-lock where b2_fin-schet.host-code = p-host-code and b2_fin-schet.code-schet = tt-fin-doc.payer-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b2_fin-schet.code-bank no-error .
  if available b2_fin-schet then
  assign
    tt-fin-doc.payer-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.payer-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.payer-c-schet    = b2_fin-schet.c-schet
    tt-fin-doc.payer-r-schet    = b2_fin-schet.r-schet
  .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* $Workfile$ e n d */