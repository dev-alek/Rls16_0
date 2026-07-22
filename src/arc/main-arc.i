/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполняет таблицу tt-kind-sum

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&SCOP ass-stk-line ~
      find first tt-kind-sum where tt-kind-sum.sum-kind = ~{&prep-1~} no-error. ~
      if not available tt-kind-sum  then do: ~
          create tt-kind-sum. ~
          assign tt-kind-sum.sum-kind = ~{&prep-1~}  ~
                 tt-kind-sum.order    = ~{&prep-2~}. ~
      end. ~
      CASE {2} : ~
      WHEN {&arh-cost} OR  ~
      WHEN {&arh-cost-service} then do: ~
           if {4} then ~
           assign ~
           tt-kind-sum.sum-{1}-base = tt-kind-sum.sum-{1}-base + (if available tt-stk-line{3} then tt-stk-line{3}.~{&prep-3~}-base else 0) ~
           tt-kind-sum.sum-{1}-rubl = tt-kind-sum.sum-{1}-rubl + (if available tt-stk-line{3} then tt-stk-line{3}.~{&prep-3~}-rubl else 0). ~
           else ~
           assign ~
           tt-kind-sum.sum-{1}-base = ? ~
           tt-kind-sum.sum-{1}-rubl = ?. ~
      end. ~
      when {&arh-crsa} OR ~
      when {&arh-crsa-service} then do: ~
          if v-r-b-base = true then do: ~
            assign tt-kind-sum.sum-{1}-rubl-sale = ? ~
                   tt-kind-sum.sum-{1}-base-sale = tt-kind-sum.sum-{1}-base-sale + (if available tt-stk-line{3} then tt-stk-line{3}.~{&prep-3~}-base else 0). ~
          end. ~
          else do: ~
            assign tt-kind-sum.sum-{1}-rubl-sale = tt-kind-sum.sum-{1}-rubl-sale + (if available tt-stk-line{3} then tt-stk-line{3}.~{&prep-3~}-rubl else 0). ~
                   tt-kind-sum.sum-{1}-base-sale = ?. ~
          end. ~
      end. ~
      otherwise do: ~
          message "Некорректный sum-type " {2} " при просмотре архива(main-arc.i)." skip ~
                  "Ошибка в расчетах." ~
          view-as alert-box error. ~
      end. ~
      end case.

for each tt-stk-line{3}:
    delete tt-stk-line{3}.
end.
run stk-lnst(input  tt-clients.obj-type,
             input  tt-clients.obj-code,
             input  tt-goods.artic,
             input  tt-goods.prod-type,
             input  tt-goods.prod-code,
             input  fact-order-{1},
             input  {2},
             input  {&root-cat-id},
             input  varis-shift-num,
             output table tt-stk-line{3}).
find first tt-stk-line{3} no-lock no-error.
if not varqnty-is-calc-{1} then do:
   assign varqnty-{1} = varqnty-{1} + (if available tt-stk-line{3} then tt-stk-line{3}.fact-qnty else 0).
   assign varqnty-is-calc-{1} = yes.
end.

&scop prep-1 "Сумма"
&scop prep-2 1
&scop prep-3 sum
{&ass-stk-line}
&scop prep-1 "НДС"
&scop prep-2 2
&scop prep-3 vat
{&ass-stk-line}
&scop prep-1 "НП"
&scop prep-2 3
&scop prep-3 slt
{&ass-stk-line}
&scop prep-1 {&road-tax-name}
&scop prep-2 4
&scop prep-3 road-tax
{&ass-stk-line}
&scop prep-1 "Акциз"
&scop prep-2 5
&scop prep-3 excise
{&ass-stk-line}
&scop prep-1 "Трансп.расходы"
&scop prep-2 6
&scop prep-3 transport
{&ass-stk-line}
&scop prep-1 "Прочие расходы"
&scop prep-2 7
&scop prep-3 other
{&ass-stk-line}
/* $Workfile$ e n d */