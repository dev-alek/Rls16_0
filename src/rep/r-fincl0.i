/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры расчета сальдо клиента с учетом талонов

Автор: Хныкин Павел Андреевич
Дата создания: 08/31/07
Author: Pavel Khnykin
Creation date: 08/31/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* ============================================================================================== */
procedure calc-cli-saldo :

  define input  parameter p-cli-type      like ub.clients.obj-type no-undo .
  define input  parameter p-cli-code      like ub.clients.obj-code no-undo .
  define input  parameter p-host-code-obj like ub.clients.obj-code no-undo .
  define input  parameter p-curr-r-b      like ub.arh-fin-doc-contr-schet.calc-curr-code no-undo .
  define input  parameter p-fact-order    as decimal   no-undo .
  define output parameter p-saldo         as decimal   no-undo .

  define variable v-saldo as decimal   no-undo .
  define variable v-sum-e as decimal   no-undo .
  define variable v-sum-i as decimal   no-undo .

do
on error undo, return error return-value
:

    run CalcOstatFin( input p-cli-type
                    , input p-cli-code
                    , input p-host-code-obj
                    , input p-curr-r-b
                    , input p-fact-order
                    , input {&income-cashless}
                    , output v-sum-e
                    , output v-sum-i
                    ) .
    assign  v-saldo = v-saldo - v-sum-e .
    run CalcOstatFin( input p-cli-type
                    , input p-cli-code
                    , input p-host-code-obj
                    , input p-curr-r-b
                    , input p-fact-order
                    , input {&expense-cashless}
                    , output v-sum-e
                    , output v-sum-i
                    ) .
    assign  v-saldo = v-saldo + v-sum-i .
    run CalcOstatFinNal( input p-cli-type
                       , input p-cli-code
                       , input p-host-code-obj
                       , input p-curr-r-b
                       , input p-fact-order
                       , input {&income-cash}
                       , output v-sum-e
                       , output v-sum-i
                       ) .
    assign  v-saldo = v-saldo - v-sum-e .
    run CalcOstatFinNal( input p-cli-type
                       , input p-cli-code
                       , input p-host-code-obj
                       , input p-curr-r-b
                       , input p-fact-order
                       , input {&expense-cash}
                       , output v-sum-e
                       , output v-sum-i
                       ) .
    assign  v-saldo = v-saldo + v-sum-i .
    run CalcOstatFinNal( input p-cli-type
                       , input p-cli-code
                       , input p-host-code-obj
                       , input p-curr-r-b
                       , input p-fact-order
                       , input {&income-payoff}
                       , output v-sum-e
                       , output v-sum-i
                       ) .
    assign  v-saldo = v-saldo - v-sum-e .
    run CalcOstatFinNal( input p-cli-type
                       , input p-cli-code
                       , input p-host-code-obj
                       , input p-curr-r-b
                       , input p-fact-order
                       , input {&expense-payoff}
                       , output v-sum-e
                       , output v-sum-i
                       ) .
    assign  v-saldo = v-saldo + v-sum-i .


    define buffer buf_clients for ub.clients.
/*    define buffer buf_goods   for goods.*/
/*    define buffer buf_wth-par for wth-par.*/
/*    define buffer buf_wth-gds for wth-gds.*/
/*    define buffer buf_wealth  for wealth.*/
/*    define buffer buf_arh-wth-cli for arh-wth-cli.*/
    define buffer buf_arh-wth-cli-tot for ub.arh-wth-cli-tot.

    &scop wth-sum-type "":U
    &scop wealth-serial 1
    define variable v-wth-saldo as decimal   no-undo .

  for each buf_clients no-lock
    where buf_clients.host-code = p-host-code-obj
  :
    find last buf_arh-wth-cli-tot no-lock
      where buf_arh-wth-cli-tot.cli-type     = p-cli-type
        and buf_arh-wth-cli-tot.cli-code     = p-cli-code
        and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
        and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
        and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Cash}
        and buf_arh-wth-cli-tot.sum-type     = {&income}
        and buf_arh-wth-cli-tot.fact-order  <= p-fact-order
    no-error .
    if available buf_arh-wth-cli-tot then do:
      assign
        v-saldo = v-saldo + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                            else                 buf_arh-wth-cli-tot.in-sum-base
      .
    end.
    find last buf_arh-wth-cli-tot no-lock
      where buf_arh-wth-cli-tot.cli-type     = p-cli-type
        and buf_arh-wth-cli-tot.cli-code     = p-cli-code
        and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
        and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
        and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Sale}
        and buf_arh-wth-cli-tot.sum-type     = {&income}
        and buf_arh-wth-cli-tot.fact-order  <= p-fact-order
    no-error .
    if available buf_arh-wth-cli-tot then do:
      assign
        v-saldo = v-saldo + if v-print-rubl then buf_arh-wth-cli-tot.in-sum-rubl
                            else                 buf_arh-wth-cli-tot.in-sum-base
      .
    end.
    find last buf_arh-wth-cli-tot no-lock
      where buf_arh-wth-cli-tot.cli-type     = p-cli-type
        and buf_arh-wth-cli-tot.cli-code     = p-cli-code
        and buf_arh-wth-cli-tot.obj-type     = buf_clients.obj-type
        and buf_arh-wth-cli-tot.obj-code     = buf_clients.obj-code
        and buf_arh-wth-cli-tot.ext-doc-type = {&WDEDT_Put_Cli}
        and buf_arh-wth-cli-tot.sum-type     = {&income}
        and buf_arh-wth-cli-tot.fact-order  <= p-fact-order
    no-error .
    if available buf_arh-wth-cli-tot then do:
      assign
        v-saldo = v-saldo + if v-print-rubl then buf_arh-wth-cli-tot.out-sum-rubl
                            else                 buf_arh-wth-cli-tot.out-sum-base
      .
    end.
  end. /* for each buf_clients no-lock */
  assign
    p-saldo = v-saldo
  .
end.

end procedure. /* calc-cli-saldo */

/* ============================================================================================== */
procedure CalcOstatFin:
  do on error undo, return error return-value :
    define input  parameter p-cli-type      like ub.clients.obj-type no-undo .
    define input  parameter p-cli-code      like ub.clients.obj-code no-undo .
    define input  parameter p-host-code-obj like ub.clients.obj-code no-undo .
    define input  parameter p-curr-r-b      like ub.arh-fin-doc-contr-schet.calc-curr-code no-undo .
    define input  parameter p-fact-order     as decimal   no-undo .
    define input  parameter p-type          as character no-undo .
    define output parameter p-sum-exp       as decimal   no-undo .
    define output parameter p-sum-inc       as decimal   no-undo .

    define buffer buf_contract                for ub.contract .
    define buffer buf_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet .

    for each buf_contract no-lock
      where buf_contract.host-code = p-host-code-obj
        and buf_contract.cli-type  = p-cli-type
        and buf_contract.cli-code  = p-cli-code
        and buf_contract.doc-type  = {&expense}
    :
      find last buf_arh-fin-doc-contr-schet no-lock
        where buf_arh-fin-doc-contr-schet.host-code        = p-host-code-obj
          and buf_arh-fin-doc-contr-schet.contract-code    = buf_contract.contract-code
          and buf_arh-fin-doc-contr-schet.code-schet       = 0
          and buf_arh-fin-doc-contr-schet.cli-code         = p-cli-code
          and buf_arh-fin-doc-contr-schet.cli-type         = p-cli-type
          and buf_arh-fin-doc-contr-schet.fin-ext-doc-type = p-type
          and buf_arh-fin-doc-contr-schet.calc-curr-code   = p-curr-r-b
          and buf_arh-fin-doc-contr-schet.sum-type         = "sum-contract"
          and buf_arh-fin-doc-contr-schet.fact-order      < p-fact-order
      no-error .
      if available buf_arh-fin-doc-contr-schet then
        assign
          p-sum-exp = p-sum-exp + buf_arh-fin-doc-contr-schet.expense
          p-sum-inc = p-sum-inc + buf_arh-fin-doc-contr-schet.income
        .
      end.
    end.

end procedure. /* CalcOstatFin */

/* ============================================================================================== */
procedure CalcOstatFinNal:
  do on error undo, return error return-value :
    define input  parameter p-cli-type      like ub.clients.obj-type no-undo .
    define input  parameter p-cli-code      like ub.clients.obj-code no-undo .
    define input  parameter p-host-code-obj like ub.clients.obj-code no-undo .
    define input  parameter p-curr-r-b      like ub.arh-fin-doc-contr-schet.calc-curr-code no-undo .
    define input  parameter p-fact-order    as decimal   no-undo .
    define input  parameter p-type          as character no-undo .
    define output parameter p-sum-exp       as decimal   no-undo .
    define output parameter p-sum-inc       as decimal   no-undo .

    define buffer buf_contract                    for ub.contract .
    define buffer buf_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal .

    for each buf_contract no-lock
      where buf_contract.host-code = p-host-code-obj
        and buf_contract.cli-type  = p-cli-type
        and buf_contract.cli-code  = p-cli-code
        and buf_contract.doc-type  = {&expense}
    :
      find last buf_arh-fin-doc-contr-schet-nal no-lock
        where buf_arh-fin-doc-contr-schet-nal.host-code        = p-host-code-obj
          and buf_arh-fin-doc-contr-schet-nal.contract-code    = buf_contract.contract-code
          and buf_arh-fin-doc-contr-schet-nal.cli-code         = p-cli-code
          and buf_arh-fin-doc-contr-schet-nal.cli-type         = p-cli-type
          and buf_arh-fin-doc-contr-schet-nal.fin-code-acc     = 0
          and buf_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = p-type
          and buf_arh-fin-doc-contr-schet-nal.curr-code        = p-curr-r-b
          and buf_arh-fin-doc-contr-schet-nal.calc-curr-code   = p-curr-r-b
          and buf_arh-fin-doc-contr-schet-nal.sum-type         = "sum-contract"
          and buf_arh-fin-doc-contr-schet-nal.fact-order       < p-fact-order
      no-error .
      if available buf_arh-fin-doc-contr-schet-nal then
        assign
          p-sum-exp = p-sum-exp + buf_arh-fin-doc-contr-schet-nal.expense
          p-sum-inc = p-sum-inc + buf_arh-fin-doc-contr-schet-nal.income
        .
      end.
    end.

end procedure. /* CalcOstatFinNal */
/* $Workfile$ e n d */