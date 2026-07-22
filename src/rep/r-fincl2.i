/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы отчета форма №2 взаиморасчет с контрагентами

Автор: Хныкин Павел Андреевич
Дата создания: 08/24/07
Author: Pavel Khnykin
Creation date: 08/24/07

{1} - таблица с контрагентами

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

    _calc-block:
    for each {1} no-lock :
      if {1}.obj-type = {&shop} or {1}.obj-type = {&stock} then do:
        next _calc-block.
      end.
      assign
        v-repfrm-str  = "Расчет для: " + {1}.obj-name
      .
      run waitfram-show in this-procedure ( input v-repfrm-str ).
      run calc-cli-saldo in this-procedure ( input {1}.obj-type
                                           , input {1}.obj-code
                                           , input v-cntxt-host-code-obj
                                           , input v-curr-r-b
                                           , input v-fact-order-start
                                           , output v-saldo-1
                                           ) .
      run calc-cli-saldo in this-procedure ( input {1}.obj-type
                                           , input {1}.obj-code
                                           , input v-cntxt-host-code-obj
                                           , input v-curr-r-b
                                           , input v-fact-order-start
                                           , output v-saldo-2
                                           ) .
      create tt-report-pay-sum.
      assign
        tt-report-pay-sum.obj-type = {1}.obj-type
        tt-report-pay-sum.obj-code = {1}.obj-code
        tt-report-pay-sum.obj-name = {1}.obj-name
        tt-report-pay-sum.pay-sum  = v-saldo-2 - v-saldo-1
      .
      for each buf_wth-gds no-lock
            where buf_wth-gds.stts = 0 ,
          each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_wth-gds.wth-code ,
          each buf_wth-ser no-lock
            where buf_wth-ser.wth-code = buf_wth-par.wth-code
              and buf_wth-ser.par-code = buf_wth-par.par-code ,
          first buf_goods no-lock
            where buf_goods.gds-code = buf_wth-gds.gds-code
      :
        /* по объектам фирмы */
        for each buf_clients no-lock
          where buf_clients.host-code = v-cntxt-host-code-obj
        :
          assign
            v-counter = v-counter + 1
          .
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Put_Cash}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-start
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-fuel-sell-money-sum-1 = v-fuel-sell-money-sum-1 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                      else                 buf_arh-wth-cli.in-sum-base
                  v-fuel-sell-units-sum-1 = v-fuel-sell-units-sum-1 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Put_Sale}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-start
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-fuel-sell-money-sum-1 = v-fuel-sell-money-sum-1 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                      else                 buf_arh-wth-cli.in-sum-base
                  v-fuel-sell-units-sum-1 = v-fuel-sell-units-sum-1 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exp_Ext}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&expense}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-start
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-1 = v-talon-give-money-sum-1 + if v-print-rubl then buf_arh-wth-cli.out-sum-rubl
                                                                        else                 buf_arh-wth-cli.out-sum-base
                  v-talon-give-units-sum-1 = v-talon-give-units-sum-1 + buf_arh-wth-cli.out-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exch}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-start
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-1 = v-talon-give-money-sum-1 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                        else                 buf_arh-wth-cli.in-sum-base
                  v-talon-give-units-sum-1 = v-talon-give-units-sum-1 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exch}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&expense}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-start
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-1 = v-talon-give-money-sum-1 - if v-print-rubl then buf_arh-wth-cli.out-sum-rubl
                                                                        else                 buf_arh-wth-cli.out-sum-base
                  v-talon-give-units-sum-1 = v-talon-give-units-sum-1 - buf_arh-wth-cli.out-qnty
                .
              end.

              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Put_Cash}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-end
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-fuel-sell-money-sum-2 = v-fuel-sell-money-sum-2 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                      else                 buf_arh-wth-cli.in-sum-base
                  v-fuel-sell-units-sum-2 = v-fuel-sell-units-sum-2 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Put_Sale}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-end
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-fuel-sell-money-sum-2 = v-fuel-sell-money-sum-2 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                      else                 buf_arh-wth-cli.in-sum-base
                  v-fuel-sell-units-sum-2 = v-fuel-sell-units-sum-2 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exp_Ext}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&expense}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-end
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-2 = v-talon-give-money-sum-2 + if v-print-rubl then buf_arh-wth-cli.out-sum-rubl
                                                                        else                 buf_arh-wth-cli.out-sum-base
                  v-talon-give-units-sum-2 = v-talon-give-units-sum-2 + buf_arh-wth-cli.out-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exch}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&income}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-end
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-2 = v-talon-give-money-sum-2 + if v-print-rubl then buf_arh-wth-cli.in-sum-rubl
                                                                        else                 buf_arh-wth-cli.in-sum-base
                  v-talon-give-units-sum-2 = v-talon-give-units-sum-2 + buf_arh-wth-cli.in-qnty
                .
              end.
              find last buf_arh-wth-cli no-lock
                where buf_arh-wth-cli.cli-type     = {1}.obj-type
                  and buf_arh-wth-cli.cli-code     = {1}.obj-code
                  and buf_arh-wth-cli.ext-doc-type = {&WDEDT_Exch}
                  and buf_arh-wth-cli.wth-code     = buf_wth-par.wth-code
                  and buf_arh-wth-cli.par-code     = buf_wth-par.par-code
                  and buf_arh-wth-cli.ser-code     = buf_wth-ser.ser-code
                  and buf_arh-wth-cli.db-num       = buf_wth-ser.db-num
                  and buf_arh-wth-cli.gds-code     = buf_goods.gds-code
                  and buf_arh-wth-cli.obj-type     = buf_clients.obj-type
                  and buf_arh-wth-cli.obj-code     = buf_clients.obj-code
                  and buf_arh-wth-cli.sum-type     = {&expense}
                  and buf_arh-wth-cli.fact-order  <= v-fact-order-end
              no-error .
              if available buf_arh-wth-cli then do:
                assign
                  v-talon-give-money-sum-2 = v-talon-give-money-sum-2 - if v-print-rubl then buf_arh-wth-cli.out-sum-rubl
                                                                        else                 buf_arh-wth-cli.out-sum-base
                  v-talon-give-units-sum-2 = v-talon-give-units-sum-2 - buf_arh-wth-cli.out-qnty
                .
              end.
        end. /* for each buf_clients no-lock  */

        if   (v-talon-give-money-sum-2 - v-talon-give-money-sum-1) <> 0
          or (v-talon-give-units-sum-2 - v-talon-give-units-sum-1) <> 0
          or (v-fuel-sell-money-sum-2  - v-fuel-sell-money-sum-1 ) <> 0
          or (v-fuel-sell-units-sum-2  - v-fuel-sell-units-sum-1 ) <> 0
        then do :
          create tt-report.
          assign
            tt-report.obj-type              = {1}.obj-type
            tt-report.obj-code              = {1}.obj-code
            tt-report.talon-name            = substitute("&1 &2 &3"
                                                        , buf_goods.gds-name
                                                        , buf_wth-par.par-val
                                                        , buf_goods.unit-base
                                                        )
            tt-report.wth-code              = buf_wth-gds.wth-code
            tt-report.par-code              = buf_wth-par.par-code
            tt-report.par-val               = buf_wth-par.par-val
            tt-report.gds-code              = buf_wth-gds.gds-code
            tt-report.talon-give-money-sum  = v-talon-give-money-sum-2 - v-talon-give-money-sum-1
            tt-report.talon-give-units-sum  = ( v-talon-give-units-sum-2 - v-talon-give-units-sum-1 ) * buf_wth-par.par-val
            tt-report.fuel-sell-money-sum   = v-fuel-sell-money-sum-2 - v-fuel-sell-money-sum-1
            tt-report.fuel-sell-units-sum   = ( v-fuel-sell-units-sum-2 - v-fuel-sell-units-sum-1 ) * buf_wth-par.par-val
            v-talon-give-money-sum-1        = 0
            v-fuel-sell-money-sum-1         = 0
            v-talon-give-units-sum-1        = 0
            v-fuel-sell-units-sum-1         = 0
            v-talon-give-money-sum-2        = 0
            v-fuel-sell-money-sum-2         = 0
            v-talon-give-units-sum-2        = 0
            v-fuel-sell-units-sum-2         = 0
          .
        end.
      end.
    end. /* for each {1} */
/* $Workfile$ e n d */