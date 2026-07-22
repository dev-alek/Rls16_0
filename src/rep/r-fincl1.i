/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы отчета форма №1 взаиморасчет с контрагентами

Автор: Хныкин Павел Андреевич
Дата создания: 08/24/07
Author: Pavel Khnykin
Creation date: 08/24/07

{1} - таблица с контрагентами

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop wth-sum-type "":U
&scop wealth-serial 1
_calc-block:
for each {1} no-lock
:
      if {1}.obj-type = {&shop} or {1}.obj-type = {&stock} then do:
        next _calc-block.
      end.
      assign
        v-pay-sum-1         = 0
        v-talon-give-sum-1  = 0
        v-fuel-sell-sum-1   = 0
        v-pay-sum-2         = 0
        v-talon-give-sum-2  = 0
        v-fuel-sell-sum-2   = 0
        v-repfrm-str  = "Расчет для: " + {1}.obj-name
      .
      run waitfram-show in this-procedure ( input v-repfrm-str ).
      for each buf_clients no-lock
        where buf_clients.host-code = v-cntxt-host-code-obj
      :
/*        for each buf_wth-gds no-lock*/
/*              where buf_wth-gds.stts = 0 ,*/
/*            each buf_wth-par no-lock*/
/*              where buf_wth-par.wth-code = buf_wth-gds.wth-code*/
/*        :*/
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Cash}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-start
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-fuel-sell-sum-1 = v-fuel-sell-sum-1 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                      else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Sale}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-start
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-fuel-sell-sum-1 = v-fuel-sell-sum-1 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                      else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exp_Ext}
              and buf_arh-wth-cli-tot.sum-type     = {&expense}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-start
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-1 = v-talon-give-sum-1 + if v-print-rubl then buf_arh-wth-cli-tot.out-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.out-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exch}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-start
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-1 = v-talon-give-sum-1 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exch}
              and buf_arh-wth-cli-tot.sum-type     = {&expense}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-start
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-1 = v-talon-give-sum-1 - if v-print-rubl then buf_arh-wth-cli-tot.out-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.out-sum-base
            .
          end.


          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Cash}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-end
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-fuel-sell-sum-2 = v-fuel-sell-sum-2 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                      else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Sale}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-end
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-fuel-sell-sum-2 = v-fuel-sell-sum-2 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                      else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exp_Ext}
              and buf_arh-wth-cli-tot.sum-type     = {&expense}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-end
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-2 = v-talon-give-sum-2 + if v-print-rubl then buf_arh-wth-cli-tot.out-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.out-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exch}
              and buf_arh-wth-cli-tot.sum-type     = {&income}
              and buf_arh-wth-cli-tot.fact-order  <= v-fact-order-end
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-2 = v-talon-give-sum-2 + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.in-sum-base
            .
          end.
          find last buf_arh-wth-cli-tot no-lock
            where buf_arh-wth-cli-tot.cli-type     = {1}.obj-type
              and buf_arh-wth-cli-tot.cli-code     = {1}.obj-code
              and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
              and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
              and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Exch}
              and buf_arh-wth-cli-tot.sum-type     = {&expense}
              and buf_arh-wth-cli-tot.fact-order  < v-fact-order-end
          no-error .
          if available buf_arh-wth-cli-tot then do:
            assign
              v-talon-give-sum-2 = v-talon-give-sum-2 - if v-print-rubl then buf_arh-wth-cli-tot.out-sum-rubl
                                                        else                 buf_arh-wth-cli-tot.out-sum-base
            .
          end.
          assign
            v-counter = v-counter + 1
          .
      end. /* buf_clients */

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
                                           , input v-fact-order-end
                                           , output v-saldo-2
                                           ) .
      create tt-report.
      assign
        tt-report.obj-type        = {1}.obj-type
        tt-report.obj-code        = {1}.obj-code
        tt-report.obj-name        = {1}.obj-name
        tt-report.pay-sum         = v-saldo-2 - v-saldo-1
        tt-report.talon-give-sum  = v-talon-give-sum-2 - v-talon-give-sum-1
        tt-report.fuel-sell-sum   = v-fuel-sell-sum-2 - v-fuel-sell-sum-1
      .

    end. /* for each {1} */

/* $Workfile$ e n d */