/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

это вспомогательный файл к r-ob-prd.p

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


        find first buf1_clients no-lock
          where buf1_clients.obj-type = buf_trn-doc.cli-type
            and buf1_clients.obj-code = buf_trn-doc.cli-code
        .
        if SelectOrg = 2 then do:
          find first buf_clients where recid( buf_clients ) = integer( org-list ) no-lock .
          if buf_trn-doc.cli-type <> buf_clients.obj-type or buf_trn-doc.cli-code <> buf_clients.obj-code then next .
        end.
        if SelectMngr = 2 then do:
          if buf_trn-doc.agnt = ? or LOOKUP (string(buf_trn-doc.agnt), mngr-list ) = 0 then next .
        end.
        if    buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}
          and buf_trn-doc.ext-doc-type <> {&TDEDT_Spi_Vnesh}    then next .

        if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then assign edt = {&TDEDT_Ras_Vnesh} .
        else do:
          if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then assign edt = {&TDEDT_Vozvrat_Vnesh} .
          else assign edt = buf_trn-doc.ext-doc-type .
        end.

        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
          case x-SelectGood : /* все товары */
            when {&g-choice}   or
            when {&g-one}      or
            when {&g-spis}     or
            when {&g-grp-prod} then do: /* список товаров */
              find first gds-list no-lock
                where gds-list.artic     = buf_doc-line.artic
                  and gds-list.prod-type = buf_doc-line.prod-type
                  and gds-list.prod-code = buf_doc-line.prod-code
                no-error .
              if not available gds-list then next .
            end.
            when {&g-prod} then do:    /* не все производители */
              find first G#cli
                where G#cli.obj-type = buf_doc-line.prod-type
                  and G#cli.obj-code = buf_doc-line.prod-code
              no-error .
              if not available G#cli then next .
            end.
            when {&g-grp} then do:    /* не все группы товаров */
              find first gds-sel-grp no-lock
                where gds-sel-grp.artic     = buf_doc-line.artic
                  and gds-sel-grp.prod-type = buf_doc-line.prod-type
                  and gds-sel-grp.prod-code = buf_doc-line.prod-code
                no-error .
              if not available gds-sel-grp then next .
            end.
          end. /* case x-SelectGood */

          run r-cost in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic , input buf_doc-line.prod-type
                                     , input buf_doc-line.prod-code  , output v1-fact-qnty        , output v1-vat-pc
                                     , output v1-slt-pc              , output v1-sum-base         , output v1-sum-rubl
                                     , output v1-vat-base            , output v1-vat-rubl         , output v1-slt-base
                                     , output v1-slt-rubl            , output v1-road-tax-base    , output v1-road-tax-rubl
                                     , output v1-transport-base      , output v1-transport-rubl   , output v1-other-base
                                     , output v1-other-rubl          , output v1-excise-base      , output v1-excise-rubl ).

          run r-sale in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic   , input buf_doc-line.prod-type
                                       , input buf_doc-line.prod-code , output v2-fact-qnty       , output v2-vat-pc
                                       , output v2-slt-pc            , output v2-sum-base         , output v2-sum-rubl
                                       , output v2-vat-base          , output v2-vat-rubl         , output v2-slt-base
                                       , output v2-slt-rubl          , output v2-road-tax-base    , output v2-road-tax-rubl
                                       , output v2-transport-base    , output v2-transport-rubl   , output v2-other-base
                                       , output v2-other-rubl        , output v2-excise-base      , output v2-excise-rubl ).

/* ******************************************************************************* */
          if use-column[ 25 ] then do: /* цена фирмы-посредника вместо учетной */
            assign
              v1-sum-base  = 0
              v1-sum-rubl  = 0
              tmp-fo       = 0
            .
            /* сначала ищем цену последнего прихода к посреднику */
            for each temp-obj :
              find last ub.doc-line no-lock
                where ub.doc-line.artic      = buf_doc-line.artic
                  and ub.doc-line.prod-type  = buf_doc-line.prod-type
                  and ub.doc-line.prod-code  = buf_doc-line.prod-code
                  and ub.doc-line.obj-type   = temp-obj.obj-type
                  and ub.doc-line.obj-code   = temp-obj.obj-code
                  and ub.doc-line.status_    = {&fact}
/*                  and ub.doc-line.fact-order < v-fact-order-start*/
                  and (ub.doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or ub.doc-line.ext-doc-type = {&TDEDT_Pri_Perem} )
              no-error .
              if available ub.doc-line then do:
                if ub.doc-line.fact-order > tmp-fo then do:
                  assign
                    v1-sum-base = ub.doc-line.price-base * v1-fact-qnty
                    v1-sum-rubl = ub.doc-line.price-rubl * v1-fact-qnty
                    tmp-fo      = ub.doc-line.fact-order
                  .
                end.
              end.
            end.
          end.
/* ******************************************************************************* */

          case SortCli :
            when 1 then do:  run Add-gds-prop (0) .  end.
            when 2 then do:  run Add-gds-prop (buf_trn-doc.agnt) .  end.
            when 3 then do:  run Add-gds-prop (buf_trn-doc.boss) .  end.
            when 4 then do:  run Add-gds-prop (buf_trn-doc.pay-code) .  end.
            when 5 then do:  run Add-gds-prop (buf1_clients.grp-code) .  end.
          end.

        end.


/* $Workfile$ e n d */