/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать тела KM-7

Автор: Комаров Иван Сергеевич
Дата создания: 06/30/10
Author: Ivan Komarov
Creation date: 06/30/10

Автор1: Белоусов Илья Александрович

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DO:
/*  ASSIGN*/
/*    v-summ-total  = v-summ-total + (temp-str.summ-end - temp-str.summ-begin)*/
/*    Lines_Counter = Lines_Counter + 1*/
/*  .*/

  if line-counter( Out-Stream ) + 4 > page-size( Out-Stream )
  then  PAGE STREAM Out-Stream.

  display stream Out-Stream
          sym1  temp-str.cash-num
          sym3  temp-str.kkm-code-prod
          sym2  temp-str.kkm-code-reg
          Sym4  temp-str.z-number
          sym5  empty-str15-5
          sym6  temp-str.summ-begin
          sym7  temp-str.summ-end
          sym8  empty-str20-8
          sym9  empty-str15-9
          sym10 empty-str09-10
          sym11 empty-str15-11
          sym12 empty-str09-12
          sym13 empty-str15-13
          sym14 empty-str09-14
          sym15
  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1}
  .

  run km7xl-write-line-data in this-procedure (
        input temp-str.cash-num
      , input temp-str.kkm-code-prod
      , input temp-str.kkm-code-reg
      , input temp-str.z-number
  ).
end.

/* $Workfile$   E n d */